from django.shortcuts import render


def lab7(request):
    if request.POST:
        name = request.POST['usrnm']
        pass1 = request.POST['pass']
        pass2 = request.POST['passagain']
        if pass1 == pass2:
            if name == 'Jimmy' and pass1 == 'Hendrix':
                context = {'result': 'Cool'}
            else:
                context = {'result': 'Bad User Name'}
        else:
            context = {'result': 'Passwords do not match!'}
        return render(request, 'lab7/lab7.html', context=context)
    else:
        return render(request, 'lab7/lab7.html')
