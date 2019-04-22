from django.db import models
from people.models import Person
from django.contrib import admin


class Topic(models.Model):
    name = models.CharField(max_length=50)

    def __str__(self):
        return self.name

    class Meta:
        pass


class Post(models.Model):
    title = models.CharField(max_length=150)
    owner = models.ForeignKey(Person, on_delete=models.CASCADE)
    body = models.CharField(max_length=1000)
    date = models.DateField(auto_now=True)
    topic = models.ForeignKey(Topic, on_delete=models.SET_NULL, null=True)

    def __str__(self):
        return self.title + " By: " + str(self.owner)

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

    def __str__(self):
        return "At: {}. By: {}. {}".format(
            self.post, self.owner, self.body)

    class Meta:
        permissions = (('can_edit_comment', 'Edit Comment'),
                       ('can_delete_comment', 'Delete Comment'))


admin.site.register(Topic)
admin.site.register(Post)
