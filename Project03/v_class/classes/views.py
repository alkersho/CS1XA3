# from django.shortcuts import render
from django.http import HttpResponse


def main(request):
    return HttpResponse('main class view')


def announcements(request):
    return HttpResponse('Class Announcements')
