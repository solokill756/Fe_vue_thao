# frozen_string_literal: true

class AdminUserService
  # Create user by admin (skip OTP)
  def create(params, skip_otp: false)
    # Check if email exists
    existing_user = User.find_by(email: params[:email])
    return Result.failure({ email: ['Email already exists'] }) if existing_user

    # Set default values
    user_params = params.dup
    user_params[:otp_verified] = true if skip_otp
    user_params[:is_active] = true if skip_otp
    user_params[:display_name] ||= user_params[:full_name]

    user = User.new(user_params)

    if user.save
      # Set user_id after save (use id converted to string)
      user.update(user_id: user.id.to_s) if user.user_id.blank?

      # Create teacher or student profile based on role
      begin
        if user.role == 'teacher'
          # Check if teacher profile already exists
          unless user.teacher
            teacher = Teacher.create(user_id: user.id)
            unless teacher.persisted?
              user.destroy
              return Result.failure({ teacher: teacher.errors.messages })
            end
          end
        elsif user.role == 'student'
          # Check if student profile already exists
          unless user.student_profile
            # Generate unique student_code
            student_code = nil
            loop do
              student_code = generate_student_code
              break unless Student.exists?(student_code: student_code)
            end
            
            student = Student.create(
              user_id: user.id,
              full_name: user.full_name,
              student_code: student_code,
              wallet_balance: 0
            )
            unless student.persisted?
              user.destroy
              return Result.failure({ student: student.errors.messages })
            end
          end
        end
        
        # Reload user to ensure associations are loaded
        user.reload
      rescue StandardError => e
        user.destroy
        return Result.failure({ error: "Failed to create profile: #{e.message}" })
      end

      Result.success(user)
    else
      Result.failure(user.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  # Update user by admin
  def update(user, params)
    # If role is being changed, handle profile migration
    if params[:role].present? && params[:role] != user.role
      # Remove old profile
      user.teacher&.destroy if user.role == 'teacher'
      user.student_profile&.destroy if user.role == 'student'

      # Update user_id if blank
      user.update(user_id: user.id.to_s) if user.user_id.blank?

      # Create new profile
      if params[:role] == 'teacher'
        unless user.teacher
          teacher = Teacher.create(user_id: user.id)
          unless teacher.persisted?
            return Result.failure({ teacher: teacher.errors.messages })
          end
        end
      elsif params[:role] == 'student'
        unless user.student_profile
          # Generate unique student_code
          student_code = nil
          loop do
            student_code = generate_student_code
            break unless Student.exists?(student_code: student_code)
          end
          
          student = Student.create(
            user_id: user.id,
            full_name: params[:full_name] || user.full_name,
            student_code: student_code,
            wallet_balance: 0
          )
          unless student.persisted?
            return Result.failure({ student: student.errors.messages })
          end
        end
      end
      
      # Reload user to ensure associations are loaded
      user.reload
    end

    # Update display_name if full_name is being updated
    params[:display_name] = params[:full_name] if params[:full_name].present? && params[:display_name].blank?

    if user.update(params)
      # Reload user after update to ensure associations are fresh
      user.reload
      Result.success(user)
    else
      Result.failure(user.errors.messages)
    end
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  # Delete user by admin
  def delete(user)
    # Reload user to ensure associations are fresh
    user.reload
    
    # Manually destroy associated profiles first to avoid issues
    # This ensures proper cleanup before user deletion
    begin
      if user.role == 'teacher'
        teacher = user.teacher
        if teacher
          # Destroy teacher profile and all its associations (classes, etc.)
          teacher.destroy
        end
      elsif user.role == 'student'
        student = user.student_profile
        if student
          # Destroy student profile and all its associations
          student.destroy
        end
      end
    rescue StandardError => e
      # If profile destruction fails, still try to delete user
      # Log the error but don't stop the process
      Rails.logger.error("Failed to destroy profile for user #{user.id}: #{e.message}")
    end

    # Reload user again to clear associations
    user.reload

    # Now destroy the user
    # Use delete_all for associations first to avoid callback issues
    user.parent_student_links.delete_all if user.parent_student_links.any?
    user.ai_conversations.delete_all if user.ai_conversations.any?
    
    # Destroy the user
    if user.destroy
      Result.success({ message: 'User deleted successfully' })
    else
      # Log errors for debugging
      Rails.logger.error("Failed to delete user #{user.id}: #{user.errors.full_messages.join(', ')}")
      Result.failure(user.errors.messages)
    end
  rescue StandardError => e
    Rails.logger.error("Error deleting user: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    Result.failure({ error: e.message })
  end

  private

  def generate_student_code
    "STD-#{SecureRandom.hex(4).upcase}"
  end
end
