# from django.shortcuts import render
from django.http import HttpResponse


def main(request):
    return HttpResponse('Main Account Page')


def login(request):
    return HttpResponse('Login Page')


def register(request):
    return HttpResponse('Registration')
