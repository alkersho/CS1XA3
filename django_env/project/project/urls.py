from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse

def helloworld(request):
    return HttpResponse("Hellor alkersho!")

urlpatterns = [
    path('admin/', admin.site.urls),
    path('e/alkersho/', helloworld, name="helloworld"),
    path('e/alkersho/test/', include('tests.urls')),
]
