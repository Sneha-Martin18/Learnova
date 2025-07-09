from django.db import models

class LeaveReportStudent(models.Model):
    id = models.AutoField(primary_key=True)
    student_id = models.IntegerField(default=1)  # Reference to user service
    leave_date = models.CharField(max_length=255)
    leave_message = models.TextField()
    leave_status = models.IntegerField(default=0)  # 0: Pending, 1: Approved, 2: Rejected
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = models.Manager()

    def __str__(self):
        return f"Leave request from Student {self.student_id}"

class LeaveReportStaff(models.Model):
    id = models.AutoField(primary_key=True)
    staff_id = models.IntegerField(default=1)  # Reference to user service
    leave_date = models.CharField(max_length=255)
    leave_message = models.TextField()
    leave_status = models.IntegerField(default=0)  # 0: Pending, 1: Approved, 2: Rejected
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = models.Manager()

    def __str__(self):
        return f"Leave request from Staff {self.staff_id}" 