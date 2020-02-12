'''
This is a course requirement for CS 192 Software Engineering II under the supervision of Asst. Prof. Ma. Rowena C. Solamo 
of the Department of Computer Science, College of Engineering, University of the Philippines, Diliman for the AY 2019-2020.

Author: Anica Galano - 2016-01120 
File Created: 1/30/2020
Development Group: CS 192 Group 5 
Client Group: CS 192 Group 5
Purpose of the Software: To provide mobile access of the DCS Codex with the feature of notifications for reminders. 

Code History: 
1/30 - register url 
1/31 - login and entries url
'''

from django.contrib import admin
from django.urls import path
from django.conf.urls import url
from DCSCodexAdmin import views 
from django.conf.urls import include
from rest_framework.authtoken import views as view

urlpatterns = [
    path('admin/', admin.site.urls),
    path('register/', views.RegisterUser.as_view(), name='register'),
    url(r'^login/', view.obtain_auth_token),
    path('entries/',views.EntryList.as_view(), name='entries'),
    path('groups/', views.GroupList.as_view(), name ='groups'),
    path('users/', views.UserList.as_view(), name='users'),
    path('update/<int:id>', views.UserUpdate.as_view(), name='update'),
    path('addgroup/', views.AddGroupList.as_view(), name='addgroup')
]
