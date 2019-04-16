from django.http import HttpResponse
from .models import Person
import json


def main(request):
    return HttpResponse('Main Account Page')


def login(request):
    return HttpResponse('Login Page')


def register(request):
    if request.body:
        post = json.loads(request.body)
        Person.objects.create_person(username=post['usrnm'],
                                     password=post['password'],
                                     first_name=post['fName'],
                                     last_name=post['lName'],
                                     email=post['email'],
                                     dob=post['dob'],
                                     gender=post['gender'])
        return HttpResponse("")
    return HttpResponse("Body is Empty")
