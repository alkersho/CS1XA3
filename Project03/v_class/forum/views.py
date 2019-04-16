# from django.shortcuts import render
from django.http import HttpResponse


def main(request):
    return HttpResponse('Main Forum page')


def view_post(request, post_id):
    return HttpResponse('View Post, id:' + str(post_id))


def create_post(request):
    return HttpResponse('Create Posts')


def edit_posts(request, post_id):
    return HttpResponse('Edit Post, id: ' + str(post_id))
