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
        try:
            Person.objects.create_person(password=post['Password'],
                                         first_name=post['First Name'],
                                         last_name=post['Last Name'],
                                         email=post['Email'],
                                         dob=post['Date of Birth'],
                                         gender=post['Gender'])
        except Exception:
            empty_fields = []
            values = list(post.values())
            keys = list(post.keys())
            for i in range(len(post)):
                if values[i] == "":
                    empty_fields.append(keys[i])
            return HttpResponse("Fields are Empty: " + ', '.join(empty_fields))
        return HttpResponse("")
    return HttpResponse("Body is Empty")
