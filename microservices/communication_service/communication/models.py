from django.db import models

class FeedBackStudent(models.Model):
    id = models.AutoField(primary_key=True)
    student_id = models.IntegerField(default=1)  # Reference to user service
    feedback = models.TextField()
    feedback_reply = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = models.Manager()

    def __str__(self):
        return f"Feedback from Student {self.student_id}"

class FeedBackStaffs(models.Model):
    id = models.AutoField(primary_key=True)
    staff_id = models.IntegerField(default=1)  # Reference to user service
    feedback = models.TextField()
    feedback_reply = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = models.Manager()

    def __str__(self):
        return f"Feedback from Staff {self.staff_id}"

class NotificationStudent(models.Model):
    id = models.AutoField(primary_key=True)
    student_id = models.IntegerField(default=1)  # Reference to user service
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = models.Manager()

    def __str__(self):
        return f"Notification for Student {self.student_id}"

class NotificationStaffs(models.Model):
    id = models.AutoField(primary_key=True)
    staff_id = models.IntegerField(default=1)  # Reference to user service
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = models.Manager()

    def __str__(self):
        return f"Notification for Staff {self.staff_id}" 