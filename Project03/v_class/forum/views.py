# from django.shortcuts import render
from django.http import HttpResponse


def main(request):
    return HttpResponse('Main Forum page')


def view_post(request):
    return HttpResponse('View Post')


def create_post(request):
    return HttpResponse('Create Posts')


def edit_posts(request):
    return HttpResponse('Edit Posts')
