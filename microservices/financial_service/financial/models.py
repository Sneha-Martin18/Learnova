from django.db import models

class Fine(models.Model):
    student_id = models.IntegerField(default=1)  # Reference to user service
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    reason = models.CharField(max_length=255)
    due_date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)
    paid = models.BooleanField(default=False)
    payment_id = models.CharField(max_length=100, null=True, blank=True)
    payment_date = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return f"Fine for Student {self.student_id} - {self.amount}"

class FinePayment(models.Model):
    fine = models.ForeignKey(Fine, on_delete=models.CASCADE)
    payment_id = models.CharField(max_length=100)
    amount_paid = models.DecimalField(max_digits=10, decimal_places=2)
    payment_date = models.DateTimeField(auto_now_add=True)
    payment_status = models.CharField(max_length=20)  # success, pending, failed
    transaction_id = models.CharField(max_length=100, null=True, blank=True)
    payment_method = models.CharField(max_length=50, null=True, blank=True)
    
    def __str__(self):
        return f"Payment {self.payment_id} for Fine {self.fine.id}" 