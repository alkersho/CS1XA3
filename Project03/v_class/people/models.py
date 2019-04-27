from django.db import models
from django.contrib.auth.models import User
from datetime import datetime
from django.contrib import admin


# manager for person model
# needed for special admin creation
class PersonManager(models.Manager):
    def create_person(self, username, first_name,
                      last_name, password, **kwargs):
        user = User.objects.create_user(username=username,
                                        password=password,
                                        email=kwargs['email'])
        date = datetime.strptime(kwargs['dob'], '%Y-%m-%d')
        user_c = len(Person.objects.all())
        admin = False
        # if it is the user to be created it is made admin
        if user_c == 0:
            admin = True
        person = self.create(user=user,
                             first_name=first_name,
                             last_name=last_name,
                             dob=date,
                             gender=kwargs['gender'])
        if admin:
            person.set_type("ADM")
        return person


class Person(models.Model):
    PERSON_TYPES = [
        ("USR", "User"),  # best abbreviaiton accident ever
        ("ADM", "Admin")
    ]
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    user_type = models.CharField(max_length=20,
                                 choices=PERSON_TYPES,
                                 default='USR')
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    dob = models.DateField(null=True)
    gender = models.CharField(max_length=20,
                              choices=[('M', 'Male'), ('F', 'Female')],
                              null=True)

    objects = PersonManager()

    # if the new type is given admin privileges
    # other they are stripped of them
    def set_type(self, new_type):
        if new_type == "ADM":
            self.user.is_staff = True
            self.user.is_admin = True
            self.user.is_superuser = True
            self.user_type = new_type
        else:
            self.user.is_staff = False
            self.user.is_admin = False
            self.user.is_superuser = False
            self.user_type = new_type
        self.user.save()
        self.save()

    def __str__(self):
        return self.user.username

    # permissions were abanoned, they serve nothin now, maybe implement later?
    class Meta:
        permissions = (('can_change_person_type', 'Change Account Type'),
                       ('can_change_name', 'Change User Name'))


admin.site.register(Person)
