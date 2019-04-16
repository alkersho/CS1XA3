# from django.shortcuts import render
from django.http import HttpResponse


def main(request):
    return HttpResponse('main class view')


def cl(request, class_name):
    return HttpResponse('Class page, ' + class_name)


def announcements(request):
    return HttpResponse('Class Announcements')
