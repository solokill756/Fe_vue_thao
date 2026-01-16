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

const classes = ref<Array<{ id: number; name: string }>>([]);
const attendanceList = ref<AttendanceStudent[]>([]);
const currentSessionId = ref<number | null>(null);
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
    return;
  }

  await loadClassSchedule();
  await loadClassStudents();
  await loadAttendanceSession();
};

const handleSelectedDateUpdate = (newDate: string) => {
  selectedDate.value = newDate;
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
  if (selectedClassId.value) {
    await loadAttendanceSession();
  }
};

// Watch for date changes as backup (after handleDateChange is defined)
watch(selectedDate, (newDate, oldDate) => {
  if (newDate !== oldDate && selectedClassId.value && newDate) {
    handleDateChange();
  }
});

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

  // Get next 4 weeks of class dates
  for (let week = 0; week < 4; week++) {
    for (const dayIndex of dayIndices) {
      const date = new Date(today);
      const currentDay = date.getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday

      // Convert to Monday=0 format for calculation
      const mondayBasedDay = currentDay === 0 ? 6 : currentDay - 1;

      // Calculate days until next occurrence
      let daysToAdd = dayIndex - mondayBasedDay;
      if (daysToAdd <= 0) daysToAdd += 7; // If already passed this week, get next week

      date.setDate(date.getDate() + daysToAdd + week * 7);

      // Check if this is today and class time has passed
      if (week === 0 && daysToAdd === 0) {
        const timeStr = schedule[dayIndex.toString()];
        if (timeStr) {
          const [startTime] = timeStr.split('-');
          const [hours, minutes] = startTime.split(':').map(Number);
          const classTime = new Date(date);
          classTime.setHours(hours, minutes, 0, 0);
          const now = new Date();
          if (classTime < now) {
            date.setDate(date.getDate() + 7);
          }
        }
      }

      // Format date as YYYY-MM-DD in local timezone (not UTC)
      // This prevents timezone conversion issues
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const dateStr = `${year}-${month}-${day}`;
      if (!dateStr || isNaN(date.getTime())) {
        // Skip invalid dates
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

  // Sort by date
  dates.sort((a, b) => a.value.localeCompare(b.value));

  // Limit to next 8 dates
  upcomingClassDates.value = dates.slice(0, 8);

  // Auto-select first upcoming date when class is selected
  if (upcomingClassDates.value.length > 0) {
    const firstDate = upcomingClassDates.value[0];
    if (firstDate && firstDate.value) {
      // Use nextTick to ensure reactive update
      nextTick(() => {
        selectedDateOption.value = firstDate.value;
        selectedDate.value = firstDate.value;
        selectedTime.value = firstDate.time || '00:00';

        // Trigger date change after selecting
        nextTick(() => {
          if (selectedClassId.value) {
            handleDateChange();
          }
        });
      });
    }
  } else {
    // If no dates available, reset to custom
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

    // Load class detail with students
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

    let totalSessions = Object.keys(classDetail.raw_schedule || {}).length * 4;
    // try {
    //   const sessionsResponse = await getAttendanceSessionsByClass(
    //     Number(selectedClassId.value)
    //   );
    //   totalSessions = sessionsResponse.data?.sessions?.length || 0;
    // } catch (error) {}

    attendanceList.value = classDetail.students_list.map((student: any) => ({
      id: student.id,
      name: student.name || 'N/A',
      student_code: student.student_code || undefined,
      status: 'present' as const,
      note: '',
      sessions_attended: student.sessions_attended || 0,
      total_sessions: totalSessions,
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

  try {
    loading.value = true;

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
      // If no records exist yet, that's fine - we'll create them when saving
    }
  } catch (error) {
    const errorMsg = getErrorMessage(error, 'teacher.attendance', t);
    toast.error(errorMsg);
  } finally {
    loading.value = false;
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
      return 'absent_w_reason';
    case 'absent':
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
  const student = attendanceList.value.find((s) => s.id === studentId);
  if (student) {
    student.status = status as AttendanceStudent['status'];
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
      const recordData = {
        status: mapStatusToApi(student.status),
        note: student.note || '',
      };

      if (
        student.attendance_record_id &&
        student.attendance_session_id === sessionId
      ) {
        // Update existing record
        return updateAttendanceRecord(
          classId,
          sessionId,
          student.attendance_record_id,
          recordData
        );
      } else {
        // Create new record
        return createAttendanceRecord(classId, sessionId, {
          student_id: student.id,
          ...recordData,
        });
      }
    });

    await Promise.all(promises);

    // Update attendance_record_id for newly created records
    const recordsResponse = await getAttendanceRecords(classId, sessionId);
    const records = recordsResponse.data || [];

    attendanceList.value = attendanceList.value.map((student) => {
      const record = records.find((r: any) => r.student_id === student.id);
      if (record) {
        return {
          ...student,
          attendance_record_id: record.id,
        };
      }
      return student;
    });

    toast.success(t('teacher.attendance.messages.saveSuccess'));
  } catch (error) {
    const errorMsg = getErrorMessage(error, 'teacher.attendance', t);
    toast.error(errorMsg);
  } finally {
    saving.value = false;
  }
};
</script>
