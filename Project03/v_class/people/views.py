from django.http import HttpResponse
from django.shortcuts import render, redirect
from .models import Person
from django.contrib.auth import authenticate, login, logout
import json


def main(request):
    if request.user.is_authenticated:
        name = request.user.username
        user_type = Person.objects.filter(
            user__username__startswith=name).first().user_type
        context = {"type": user_type}
        return render(request, 'people/account.html', context=context)
    
    return redirect("people:login")


def login_page(request):
    if request.body:
        post = json.loads(request.body)
        print(post)
        user = authenticate(username=post['userName'],
                            password=post['password'])
        if user is not None:
            login(request, user)
            print("logged in")
            return HttpResponse("")
        else:
            return HttpResponse("Wrong Username/Passowrd")
    else:
        return render(request, 'people/login.html')


def logout_page(request):
    logout(request)
    return redirect("people:login")


def register(request):
    if request.body:
        post = json.loads(request.body)
        try:
            user = Person.objects.create_person(password=post['Password'],
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
        login(request, user.user)
        return HttpResponse("")
    return render(request, "people/register.html")
