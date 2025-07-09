from django.db import models

class Attendance(models.Model):
    # Subject Attendance
    id = models.AutoField(primary_key=True)
    subject_id = models.IntegerField(default=1)  # Reference to academic service
    attendance_date = models.DateField()
    session_year_id = models.IntegerField(default=1)  # Reference to academic service
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = models.Manager()

    def __str__(self):
        return f"Attendance for {self.attendance_date}"

class AttendanceReport(models.Model):
    # Individual Student Attendance
    id = models.AutoField(primary_key=True)
    student_id = models.IntegerField(default=1)  # Reference to user service
    attendance_id = models.ForeignKey(Attendance, on_delete=models.CASCADE)
    status = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = models.Manager()

    def __str__(self):
        return f"Student {self.student_id} - {'Present' if self.status else 'Absent'}" 