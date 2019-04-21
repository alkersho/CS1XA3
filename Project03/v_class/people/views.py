from django.http import HttpResponse
from django.shortcuts import render, redirect
from .models import Person
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User
import json


def main(request):
    if request.user.is_authenticated:
        if request.body:
            post = json.loads(request.body)
            email = post.get("email", "")
            newPass = post.get("newPass", "")
            if email == "":
                if newPass == "":
                    return HttpResponse("Please Enter a Password!")
                else:
                    temp_user = authenticate(username=request.user.username,
                                             password=post['currentPass'])
                    if temp_user is not None:
                        u = User.objects.get(username=request.user.username)
                        u.set_password(newPass)
                        u.save()
                        login(request, u)
                        return HttpResponse("")
                    else:
                        return HttpResponse("Wrong Passowrd!")
                return HttpResponse("Please Enter an email!")
            else:
                request.user.email = email
                request.user.save()
                return HttpResponse("")

            return HttpResponse("")
        username = request.user.username
        user = Person.objects.filter(
            user__username__startswith=username).first()
        fName = user.first_name
        lName = user.last_name
        email = user.user.email
        gender = user.get_gender_display()
        dob = user.dob.strftime("%d/%m/%Y")
        classes = [x.name for x in user.classes.all()]
        user_type = user.user_type
        type_display = user.get_user_type_display()
        context = {"type": user_type,
                   "typeDisplay": type_display,
                   "fname": fName,
                   "lname": lName,
                   "userName": username,
                   "email": email,
                   "gender": gender,
                   "classes": classes,
                   "dob": dob}
        return render(request, 'people/account.html', context=context)
    return redirect("people:login")


def acount_list(request):
    if request.body:
        post = json.loads(request.body)
        if "userSearch" in post.keys():
            users_types = [{"username": x.user.username,
                            "userType": x.user_type}
                           for x in Person.objects.filter(
                                   user__username__contains=post['userSearch']
                           )]
            responce = json.dumps({"responce": users_types})
            return HttpResponse(responce)
        else:
            p = Person.objects.filter(
                user__username__startswith=post['username']).first()
            p.user_type = post['newType']
            p.save()
            return HttpResponse("")
    users_types = [{"username": x.user.username,
                    "userType": x.user_type}
                   for x in Person.objects.all()]
    responce = json.dumps({"responce": users_types})
    return HttpResponse(responce)


def login_page(request):
    if request.body:
        post = json.loads(request.body)
        user = authenticate(username=post['userName'],
                            password=post['password'])
        if user is not None:
            login(request, user)
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
