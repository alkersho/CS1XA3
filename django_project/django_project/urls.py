from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('e/alkersho/admin/', admin.site.urls),
    path('e/alkersho/lab7/', include('lab7.urls')),
]
