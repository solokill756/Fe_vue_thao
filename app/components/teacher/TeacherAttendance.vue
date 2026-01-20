<template>
  <div class="h-full flex flex-col space-y-4">
    <!-- Top Control Bar -->
    <AttendanceControlBar
      :selected-class-id="selectedClassId || ''"
      :selected-date="selectedDate || ''"
      :selected-date-option="selectedDateOption"
      :classes="classes"
      :upcoming-class-dates="upcomingClassDates"
      :attendance-stats="attendanceStats"
      :total-students="filteredAttendanceList.length"
      :saving="saving"
      @update:selected-class-id="handleClassIdUpdate"
      @class-change="handleClassChange"
      @update:selected-date="handleSelectedDateUpdate"
      @update:selected-date-option="selectedDateOption = $event"
      @date-option-change="handleDateOptionChange"
      @date-change="handleDateChange"
      @mark-all-present="markAllPresent"
      @save-attendance="saveAttendance"
    />

    <!-- Main Attendance List -->
    <div
      class="bg-white rounded-xl border border-slate-200 shadow-sm flex-1 overflow-hidden flex flex-col"
    >
      <!-- Toolbar inside list -->
      <AttendanceToolbar
        :search-query="searchQuery"
        @update:search-query="searchQuery = $event"
      />

      <AttendanceTable
        :students="filteredAttendanceList"
        @student-status-change="handleStudentStatusChange"
        @student-note-change="handleStudentNoteChange"
        @student-add-tag="handleStudentAddTag"
        @student-alert-parent="alertParent"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import AttendanceControlBar from './attendance/AttendanceControlBar.vue';
import AttendanceToolbar from './attendance/AttendanceToolbar.vue';
import AttendanceTable from './attendance/AttendanceTable.vue';
import { useTeacherClassApi } from '../../composables/useTeacherClassApi';
import { useAttendanceApi } from '../../composables/useAttendanceApi';
import { useToast } from 'vue-toastification';
import { useI18n } from 'vue-i18n';
import { getErrorMessage } from '../../utils/errorHandler';
import { nextTick, watch } from 'vue';

const { t } = useI18n();
const toast = useToast();
const {
  fetchTeacherClasses,
  fetchTeacherClassDetail,
  createAttendanceSession,
} = useTeacherClassApi();
const {
  getAttendanceSessionsByClass,
  getAttendanceRecords,
  createAttendanceRecord,
  updateAttendanceRecord,
} = useAttendanceApi();

interface AttendanceStudent {
  id: number;
  name: string;
  student_code?: string;
  status:
    | 'present'
    | 'late'
    | 'absent'
    | 'absent_w_reason'
    | 'absent_no_reason';
  note: string;
  sessions_attended?: number;
  total_sessions?: number;
  avatar?: string;
  attendance_record_id?: number;
  attendance_session_id?: number;
}

const selectedClassId = ref('') as Ref<string>;
const selectedDate = ref(new Date().toISOString().split('T')[0]);
const selectedTime = ref<string>('00:00');
const selectedDateOption = ref<string>('custom');
const searchQuery = ref('');
const saving = ref(false);
const loading = ref(false);
const isLoadingSession = ref(false); // Flag to prevent multiple simultaneous API calls

const classes = ref<Array<{ id: number; name: string }>>([]);
const attendanceList = ref<AttendanceStudent[]>([]);
const currentSessionId = ref<number | null>(null);
const currentSessionDate = ref<string | null>(null); // Track which date the current session is for
const classSchedule = ref<Record<string, string> | null>(null);
const upcomingClassDates = ref<
  Array<{ value: string; label: string; time?: string }>
>([]);

// Fetch classes on mount
const {
  data: classesData,
  pending: classesPending,
  refresh: refreshClasses,
} = await useAsyncData('teacher-classes-for-attendance', async () => {
  try {
    const response = await fetchTeacherClasses({ status: 'active' });
    const classesList = response.data?.classes || [];

    // Update classes ref immediately
    classes.value = classesList.map((cls) => ({ id: cls.id, name: cls.name }));

    return classesList;
  } catch (error) {
    const errorMsg = getErrorMessage(error, 'teacher.attendance', t);
    toast.error(errorMsg);
    classes.value = [];
    return [];
  }
});

// Watch for changes and update classes
watch(
  classesData,
  (newData) => {
    if (newData && newData.length > 0) {
      classes.value = newData.map((cls) => ({ id: cls.id, name: cls.name }));
    }
  },
  { immediate: true }
);

const handleClassIdUpdate = (newClassId: string) => {
  selectedClassId.value = newClassId || '';
  // Don't call handleClassChange here - let @class-change event handle it
};

const handleClassChange = async () => {
  if (!selectedClassId.value) {
    attendanceList.value = [];
    classSchedule.value = null;
    upcomingClassDates.value = [];
    selectedDateOption.value = 'custom';
    currentSessionId.value = null;
    currentSessionDate.value = null;
    return;
  }

  // Reset session tracking when class changes
  currentSessionId.value = null;
  currentSessionDate.value = null;
  
  await loadClassSchedule();
  await loadClassStudents();
  await loadAttendanceSession();
};

const handleSelectedDateUpdate = (newDate: string) => {
  if (selectedDate.value === newDate) return; // Prevent unnecessary updates
  selectedDate.value = newDate;
  
  // Update selectedTime based on schedule if available
  if (classSchedule.value && newDate) {
    try {
      const date = new Date(newDate);
      const dayIndex = date.getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
      const mondayBasedDay = dayIndex === 0 ? 6 : dayIndex - 1; // Convert to Monday=0
      const timeStr = classSchedule.value[mondayBasedDay.toString()];
      
      if (timeStr) {
        const startTime = timeStr.split('-')[0]?.trim();
        if (startTime) {
          selectedTime.value = startTime;
        }
      }
    } catch (error) {
      console.warn('Failed to extract time from schedule:', error);
    }
  }
  
  // Trigger date change after value is updated
  nextTick(() => {
    if (selectedClassId.value) {
      handleDateChange();
    }
  });
};

const handleDateOptionChange = () => {
  if (selectedDateOption.value !== 'custom') {
    const selectedOption = upcomingClassDates.value.find(
      (d) => d.value === selectedDateOption.value
    );
    selectedDate.value = selectedDateOption.value;
    selectedTime.value = selectedOption?.time || '00:00';
    nextTick(() => {
      if (selectedClassId.value) {
        handleDateChange();
      }
    });
  }
};

const handleDateChange = async () => {
  if (selectedClassId.value && !isLoadingSession.value) {
    await loadAttendanceSession();
  }
};

// Watch for date changes as backup (after handleDateChange is defined)
// Use immediate: false to prevent initial trigger
watch(selectedDate, (newDate, oldDate) => {
  if (newDate !== oldDate && selectedClassId.value && newDate && !isLoadingSession.value) {
    handleDateChange();
  }
}, { immediate: false });

const loadClassSchedule = async () => {
  if (!selectedClassId.value) return;

  try {
    const response = await fetchTeacherClassDetail(
      Number(selectedClassId.value)
    );
    const classDetail = response.data;

    if (classDetail) {
      // Handle schedule - it might be a JSON string or already an object
      let schedule = classDetail.raw_schedule;

      // If schedule is a string, try to parse it
      if (typeof schedule === 'string') {
        try {
          schedule = JSON.parse(schedule);
        } catch (e) {
          schedule = null;
        }
      }

      classSchedule.value = schedule as Record<string, string> | null;

      calculateUpcomingDates(schedule);
    }
  } catch (error) {
    const errorMsg = getErrorMessage(error, 'teacher.attendance', t);
    toast.error(errorMsg);
  }
};

const calculateUpcomingDates = (schedule: any) => {
  if (!schedule || typeof schedule !== 'object') {
    upcomingClassDates.value = [];
    return;
  }

  const dayIndices = Object.keys(schedule)
    .map(Number)
    .filter((idx) => !isNaN(idx) && idx >= 0 && idx <= 6);

  if (dayIndices.length === 0) {
    upcomingClassDates.value = [];
    return;
  }

  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const dates: Array<{ value: string; label: string; time?: string }> = [];


  for (let week = -4; week < 1; week++) {
    for (const dayIndex of dayIndices) {
      
      const date = new Date(today);
      
    
      const currentDay = date.getDay(); 
      const mondayBasedDay = currentDay === 0 ? 6 : currentDay - 1; 
      
      const daysToMondayOfTargetWeek = week * 7 - mondayBasedDay;
      
      date.setDate(date.getDate() + daysToMondayOfTargetWeek + dayIndex);

      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const dateStr = `${year}-${month}-${day}`;
      if (!dateStr || isNaN(date.getTime())) {
        continue;
      }

      const dayNames = [
        t('teacher.classes.scheduleTab.days.monday'),
        t('teacher.classes.scheduleTab.days.tuesday'),
        t('teacher.classes.scheduleTab.days.wednesday'),
        t('teacher.classes.scheduleTab.days.thursday'),
        t('teacher.classes.scheduleTab.days.friday'),
        t('teacher.classes.scheduleTab.days.saturday'),
        t('teacher.classes.scheduleTab.days.sunday'),
      ];

      const dayName = dayNames[dayIndex] || '';
      const timeStr = schedule[dayIndex.toString()] || '';
      const formattedDate = date.toLocaleDateString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
      });
      const label = `${dayName} ${formattedDate}${
        timeStr ? ` (${timeStr})` : ''
      }`;

      const startTime = timeStr ? timeStr.split('-')[0] : '00:00';

      if (!dates.find((d) => d.value === dateStr)) {
        dates.push({ value: dateStr, label, time: startTime });
      }
    }
  }

  
  dates.sort((a, b) => a.value.localeCompare(b.value));

  
  upcomingClassDates.value = dates.slice(-20);


  if (upcomingClassDates.value.length > 0) {
    const todayStr = today.toISOString().split('T')[0];
    const todayDateOption = upcomingClassDates.value.find(d => d.value === todayStr);
    const dateToSelect = todayDateOption || upcomingClassDates.value[upcomingClassDates.value.length - 1];
    
    if (dateToSelect && dateToSelect.value) {
      if (selectedDate.value !== dateToSelect.value) {
        nextTick(() => {
          selectedDateOption.value = dateToSelect.value;
          selectedDate.value = dateToSelect.value;
          selectedTime.value = dateToSelect.time || '00:00';

          nextTick(() => {
            if (selectedClassId.value && !isLoadingSession.value) {
              handleDateChange();
            }
          });
        });
      }
    }
  } else {
    selectedDateOption.value = 'custom';
  }
};

const loadClassStudents = async () => {
  if (!selectedClassId.value) {
    attendanceList.value = [];
    return;
  }

  try {
    loading.value = true;

    const response = await fetchTeacherClassDetail(
      Number(selectedClassId.value)
    );
    const classDetail = response.data;

    if (!classDetail) {
      toast.error(t('teacher.attendance.messages.classNotFound'));
      return;
    }

    if (!classDetail.students_list || classDetail.students_list.length === 0) {
      toast.info(t('teacher.attendance.messages.noStudents'));
      attendanceList.value = [];
      return;
    }

    attendanceList.value = classDetail.students_list.map((student: any) => ({
      id: student.id,
      name: student.name || 'N/A',
      student_code: student.student_code || undefined,
      status: 'present' as const,
      note: '',
      sessions_attended: student.sessions_attended ?? 0,
      total_sessions: student.total_sessions ?? 0,
      avatar: student.avatar || undefined,
      attendance_record_id: undefined,
    }));
  } catch (error) {
    const errorMsg = getErrorMessage(error, 'teacher.attendance', t);
    toast.error(errorMsg);
    attendanceList.value = [];
  } finally {
    loading.value = false;
  }
};

const loadAttendanceSession = async () => {
  if (!selectedClassId.value || !selectedDate.value) return;
  
  // Prevent multiple simultaneous calls
  if (isLoadingSession.value) return;
  
  

  try {
    isLoadingSession.value = true;
    loading.value = true;

    // First, try to get existing sessions for this class and date
    try {
      const sessionsResponse = await getAttendanceSessionsByClass(
        Number(selectedClassId.value)
      );
      
      const sessions = sessionsResponse.data?.sessions || [];
      const existingSession = sessions.find(
        (s: any) => s.date === selectedDate.value
      );
      
      if (existingSession) {
        // Use existing session
        currentSessionId.value = existingSession.id;
        currentSessionDate.value = selectedDate.value;
        
        // Load attendance records
        const recordsResponse = await getAttendanceRecords(
          Number(selectedClassId.value),
          existingSession.id
        );

        const records = recordsResponse.data || [];
        if (records.length > 0) {
          attendanceList.value = attendanceList.value.map((student) => {
            const record = records.find((r: any) => r.student_id === student.id);
            if (record) {
              return {
                ...student,
                status: mapStatusFromApi(record.status),
                note: record.note || '',
                attendance_record_id: record.id,
                attendance_session_id: existingSession.id,
              };
            }
            return student;
          });
        }
        
        loading.value = false;
        isLoadingSession.value = false;
        return;
      }
    } catch (error) {
      // If getting sessions fails, continue to create new one
      console.warn('Failed to get existing sessions:', error);
    }

    // No existing session found, create a new one
    const sessionResponse = await createAttendanceSession(
      Number(selectedClassId.value),
      selectedDate.value,
      selectedTime.value
    );

    const sessionId = sessionResponse.data?.session?.id;
    if (!sessionId) {
      throw new Error('Failed to get attendance session');
    }

    currentSessionId.value = sessionId;
    currentSessionDate.value = selectedDate.value;

    try {
      const recordsResponse = await getAttendanceRecords(
        Number(selectedClassId.value),
        sessionId
      );

      const records = recordsResponse.data || [];
      // Map records to attendance list
      if (records.length > 0) {
        attendanceList.value = attendanceList.value.map((student) => {
          const record = records.find((r: any) => r.student_id === student.id);
          if (record) {
            return {
              ...student,
              status: mapStatusFromApi(record.status),
              note: record.note || '',
              attendance_record_id: record.id,
              attendance_session_id: sessionId,
            };
          }
          return student;
        });
      }
    } catch (error) {
      toast.error(getErrorMessage(error, 'teacher.attendance', t));
    }
  } catch (error) {
    const errorMsg = getErrorMessage(error, 'teacher.attendance', t);
    toast.error(errorMsg);
  } finally {
    loading.value = false;
    isLoadingSession.value = false;
  }
};

const mapStatusFromApi = (
  status: string
): 'present' | 'late' | 'absent' | 'absent_w_reason' | 'absent_no_reason' => {
  switch (status) {
    case 'present':
      return 'present';
    case 'late':
      return 'late';
    case 'absent_w_reason':
      return 'absent_w_reason';
    case 'absent_no_reason':
      return 'absent_no_reason';
    default:
      return 'present';
  }
};

const mapStatusToApi = (
  status: string
): 'present' | 'late' | 'absent_w_reason' | 'absent_no_reason' => {
  switch (status) {
    case 'present':
      return 'present';
    case 'late':
      return 'late';
    case 'excused':
    case 'absent_w_reason':
      return 'absent_w_reason';
    case 'absent':
    case 'absent_no_reason':
      return 'absent_no_reason';
    default:
      return 'present';
  }
};

const filteredAttendanceList = computed(() => {
  if (!searchQuery.value) return attendanceList.value;

  const query = searchQuery.value.toLowerCase();
  return attendanceList.value.filter(
    (student) =>
      student.name.toLowerCase().includes(query) ||
      student.student_code?.toLowerCase().includes(query)
  );
});

const attendanceStats = computed(() => {
  const stats = { present: 0, late: 0, absent: 0 };
  attendanceList.value.forEach((s) => {
    if (s.status === 'present') stats.present++;
    else if (s.status === 'late') stats.late++;
    else if (s.status === 'absent_no_reason' || s.status === 'absent_w_reason')
      stats.absent++;
  });
  return stats;
});

const markAllPresent = () => {
  attendanceList.value.forEach((s) => (s.status = 'present'));
  toast.success(t('teacher.attendance.messages.allMarkedPresent'));
};

const addTag = (student: AttendanceStudent, tag: string) => {
  if (student.note) {
    student.note += `, ${tag}`;
  } else {
    student.note = tag;
  }
};

const alertParent = (student: AttendanceStudent) => {
  toast.info(
    t('teacher.attendance.messages.alertParentSent', { name: student.name })
  );
  // TODO: Implement actual parent alert API
};

const handleStudentStatusChange = (studentId: number, status: string) => {
  const index = attendanceList.value.findIndex((s) => s.id === studentId);
  if (index !== -1) {
    const student = attendanceList.value[index];
    if (student) {
    
      student.status = status as AttendanceStudent['status'];
    }
  }
};

const handleStudentNoteChange = (studentId: number, note: string) => {
  const student = attendanceList.value.find((s) => s.id === studentId);
  if (student) {
    student.note = note;
  }
};

const handleStudentAddTag = (studentId: number, tag: string) => {
  const index = attendanceList.value.findIndex((s) => s.id === studentId);
  if (index !== -1) {
    const student = attendanceList.value[index];
    if (!student) return;

    // Update note
    const newNote = student.note ? `${student.note}, ${tag}` : tag;

    // Update the student object in the array to trigger reactivity
    attendanceList.value[index] = {
      ...student,
      note: newNote,
    };
  }
};

const saveAttendance = async () => {
  if (!selectedClassId.value || !selectedDate.value) {
    toast.error(t('teacher.attendance.messages.selectClassAndDate'));
    return;
  }

  if (!currentSessionId.value) {
    toast.error(t('teacher.attendance.messages.noSession'));
    return;
  }

  try {
    saving.value = true;

    const classId = Number(selectedClassId.value);
    const sessionId = currentSessionId.value;
    // Save or update attendance records for each student
    const promises = attendanceList.value.map(async (student) => {
      const mappedStatus = mapStatusToApi(student.status);
      const recordData = {
        status: mappedStatus,
        note: student.note || '',
      };
      if (
        student.attendance_record_id &&
        student.attendance_session_id === sessionId
      ) {
        try {
          const result = await updateAttendanceRecord(
            classId,
            sessionId,
            student.attendance_record_id,
            recordData
          );
          return result;
        } catch (error) {
          console.error('Error updating record:', error);
          throw error;
        }
      } else {
        return createAttendanceRecord(classId, sessionId, {
          student_id: student.id,
          ...recordData,
        });
      }
    });

    await Promise.all(promises);
    await loadClassStudents();
    await loadAttendanceSession();
    
    toast.success(t('teacher.attendance.messages.saveSuccess'));
  } catch (error) {
    const errorMsg = getErrorMessage(error, 'teacher.attendance', t);
    toast.error(errorMsg);
  } finally {
    saving.value = false;
  }
};
</script>
