from django.db import models
from people.models import Person
from classes.models import Class


class Post(models.Model):
    title = models.CharField(max_length=150)
    owner = models.ForeignKey(Person, on_delete=models.CASCADE)
    body = models.CharField(max_length=1000)
    cl = models.ForeignKey(Class, on_delete=models.CASCADE)
    date = models.DateField(auto_now=True)

    class Meta:
        permissions = (('can_edit_title', 'Edit Title'),
                       ('can_delete_post', 'Delete Post'),
                       ('can_edit_post', 'Edit Post'))


class Comment(models.Model):
    owner = models.ForeignKey(Person, on_delete=models.CASCADE)
    body = models.CharField(max_length=500)
    sub_comment = models.ForeignKey('self', on_delete=models.CASCADE)
    vote = models.IntegerField()
    post = models.ForeignKey(Post, on_delete=models.CASCADE)
    date = models.DateField(auto_now=True)

    class Meta:
        permissions = (('can_edit_comment', 'Edit Comment'),
                       ('can_delete_comment', 'Delete Comment'))
