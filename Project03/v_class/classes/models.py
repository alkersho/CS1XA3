from django.db import models


class Class(models.Model):
    name = models.CharField(max_length=50)
    code = models.CharField(max_length=4)

    class Meta:
        permissions = (('can_add_class', 'Add Classes'),
                       ('can_edit_class', 'Edit Classes'))
