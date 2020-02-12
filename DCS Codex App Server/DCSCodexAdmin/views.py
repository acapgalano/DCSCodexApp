'''
This is a course requirement for CS 192 Software Engineering II under the supervision of Asst. Prof. Ma. Rowena C. Solamo 
of the Department of Computer Science, College of Engineering, University of the Philippines, Diliman for the AY 2019-2020.

Author: Anica Galano - 2016-01120 
File Created: 1/30/2020
Development Group: CS 192 Group 5 
Client Group: CS 192 Group 5
Purpose of the Software: To provide mobile access of the DCS Codex with the feature of notifications for reminders. 

Code History:
1/30 - RegisteredUser View 
1/31 - EntryList View 
'''

from django.shortcuts import render
from rest_framework.response import Response
from rest_framework import status
from rest_framework import generics
from .models import User, Group, Entry
from .serializers import RegisterUserSerializer, EntrySerializer, UserSerializer, GroupSerializer, GroupsSerializer, UserUpdateSerializer
from rest_framework.generics import ListAPIView, CreateAPIView
from django.shortcuts import get_object_or_404

# RegisterUser view used for account registration
class RegisterUser(CreateAPIView):
    serializer_class = RegisterUserSerializer

# EntryList view used to send all Entry objects
class EntryList(ListAPIView):
    queryset = Entry.objects.all()
    serializer_class = EntrySerializer

class UserList(ListAPIView):
	queryset = User.objects.all()
	serializer_class = UserSerializer

class GroupList(ListAPIView):
	queryset = Group.objects.all()
	serializer_class = GroupsSerializer

class AddGroupList(ListAPIView):
	queryset = Group.objects.exclude(users=2)
	serializer_class = GroupsSerializer

class UserUpdate(generics.RetrieveUpdateAPIView):
	serializer_class = UserUpdateSerializer

	def get_object(self):
		id = self.kwargs['id']
		return get_object_or_404(User, id=id)
	
	def put(self, request, *args, **kwargs):
		return self.update(request, *args, **kwargs)