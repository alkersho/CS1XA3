from django.db import models
from django.contrib.auth.models import User
from datetime import datetime


class PersonManager(models.Manager):
    def create_person(self, first_name, last_name, password, **kwargs):
        username = last_name + first_name[0]
        users = Person.objects.filter(
            user__username__startswith=username).order_by('user__username')
        likeNames = [x.user.username for x in users.all()]
        print()
        if len(likeNames) > 0:
            latest = likeNames[-1]
            try:
                number = int(latest.split(username)[-1]) + 1
            except ValueError:
                number = 1
            username += str(number)
            print(username)
        user = User.objects.create_user(username=username,
                                        password=password,
                                        email=kwargs['email'])
        date = datetime.strptime(kwargs['dob'], '%Y-%m-%d')
        if 'user_type' in kwargs:
            person = self.create(user=user,
                                 first_name=first_name,
                                 last_name=last_name,
                                 dob=date,
                                 gender=kwargs['gender'],
                                 user_type=kwargs['user_type'])
        person = self.create(user=user,
                             first_name=first_name,
                             last_name=last_name,
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
