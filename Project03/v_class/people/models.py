from django.db import models
from django.contrib.auth.models import User
from datetime import datetime


class PersonManager(models.Manager):
    def create_person(self, username, password, **kwargs):
        # username = kwargs['last_name'] + kwargs['first_name'][0]
        user = User.objects.create_user(username=username,
                                        password=password,
                                        email=kwargs['email'])
        date = datetime.strptime(kwargs['dob'], '%Y-%m-%d')
        person = self.create(user=user,
                             user_type='STD',
                             first_name=kwargs['first_name'],
                             last_name=kwargs['last_name'],
                             dob=date,
                             gender=kwargs['gender'])
        return person


class Person(models.Model):
    PERSON_TYPES = [
        ("TCHR", "Teacher"),
        ("STD", "Student"),  # best abbreviaiton accident ever
        ("ADM", "Admin")
    ]
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    user_type = models.CharField(max_length=20,
                                 choices=PERSON_TYPES,
                                 default='STD')
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    classes = models.ManyToManyField('classes.Class')
    dob = models.DateField(null=True)
    gender = models.CharField(max_length=20,
                              choices=[('M', 'Male'), ('F', 'Female')],
                              null=True)

    objects = PersonManager()

    class Meta:
        permissions = (('can_change_person_type', 'Change Account Type'),
                       ('can_change_name', 'Change User Name'))
