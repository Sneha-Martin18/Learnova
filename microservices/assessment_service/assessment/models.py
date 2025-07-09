from django.db import models

class StudentResult(models.Model):
    id = models.AutoField(primary_key=True)
    student_id = models.IntegerField(default=1)  # Reference to user service
    subject_id = models.IntegerField(default=1)  # Reference to academic service
    subject_exam_marks = models.FloatField(default=0)
    subject_assignment_marks = models.FloatField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = models.Manager()

    def __str__(self):
        return f"Result for Student {self.student_id} - Subject {self.subject_id}"

class Assignment(models.Model):
    subject_id = models.IntegerField(default=1)  # Reference to academic service
    title = models.CharField(max_length=255)
    description = models.TextField()
    due_date = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Assignment: {self.title}"

class AssignmentSubmission(models.Model):
    STATUS_CHOICES = (
        ('submitted', 'Submitted'),
        ('graded', 'Graded'),
    )
    
    student_id = models.IntegerField(default=1)  # Reference to user service
    assignment_id = models.ForeignKey(Assignment, on_delete=models.CASCADE)
    submission_file = models.FileField(upload_to='assignments/submissions/')
    submitted_at = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='submitted')
    marks = models.FloatField(null=True, blank=True)
    
    def __str__(self):
        return f"Submission by Student {self.student_id} for {self.assignment_id.title}"
    
    class Meta:
        unique_together = ('student_id', 'assignment_id') 