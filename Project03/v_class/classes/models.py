from django.db import models
from people.models import Person


class Class(models.Model):
    name = models.CharField(max_length=50)
    code = models.CharField(max_length=4)

    class Meta:
        permissions = (('can_add_class', 'Add Classes'),
                       ('can_edit_class', 'Edit Classes'))


# announcements
class Announcement(models.Model):
    title = models.CharField(max_length=100)
    body = models.CharField(max_length=500)
    owner = models.ForeignKey(Person, on_delete=models.SET_NULL)
    cl = models.ForeignKey(Class, on_delete=models.CASCADE)
    date = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['cl', 'date']
        permissions = [('can_make_announcement', 'Create Announcement'),
                       ('can_edit_announcement', 'Edit Announcement'),
                       ('can_delete_announcement', 'Delete Announcement')]
