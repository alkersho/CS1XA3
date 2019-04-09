from django.db import models
from django.contrib.auth.models import User
from classes.models import Class


class PersonManager(models.Manager):
    def create_person(self, username, password, **kwargs):
        user = User.objects.create_user(username=User, password=password)
        person = self.create(user=user,
                             user_type=kwargs['user_type'],
                             first_name=kwargs['first_name'],
                             last_name=kwargs['last_name'])
        return person


class Person(models.Model):
    PERSON_TYPES = [
        ("TCHR", "Teacher"),
        ("STD", "Student"),
        ("ADM", "Admin")
    ]
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    user_type = models.CharField(max_length=20, choices=PERSON_TYPES)
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    classes = models.ManyToManyField(Class)
    dob = models.DateField(null=True)
    gender = models.CharField(max_length=20,
                              choices=[('M', 'Male'), ('F', 'Female')],
                              null=True)

    objects = PersonManager()

    class Meta:
        permissions = (('can_change_person_type', 'Change Account Type'),
                       ('can_change_name', 'Change User Name'))
