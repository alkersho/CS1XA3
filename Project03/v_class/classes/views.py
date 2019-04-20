# from django.shortcuts import render
from django.http import HttpResponse
from people.models import Person


def main(request):
    return HttpResponse('main class view')


def cl(request, class_name):
    return HttpResponse('Class page, ' + class_name)


def announcements(request):
    return HttpResponse('Class Announcements')


def classes(request):
    username = request.user.username
    classes_objects = Person.objects.filter(
        user__username__startswith=username).first().classes.all()
    class_list = [x.name for x in classes_objects]
    response = {"classes": class_list}
    return HttpResponse(response)
