from django.db import models

class Task(models.Model):
    text = models.TextField()
    sentiment = models.CharField(max_length=50, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Task {self.id}"
