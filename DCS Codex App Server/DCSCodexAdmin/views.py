'''
This is a course requirement for CS 192 Software Engineering II under the supervision of Asst. Prof. Ma. Rowena C. Solamo 
of the Department of Computer Science, College of Engineering, University of the Philippines, Diliman for the AY 2019-2020.

Author: Anica Galano - 2016-01120 and Ken Tabagan - 2017-00897
File Created: 1/30/2020
Development Group: CS 192 Group 5 
Client Group: CS 192 Group 5
Purpose of the Software: To provide mobile access of the DCS Codex with the feature of notifications for reminders. 

Code History:
1/30 - RegisteredUser View 
1/31 - EntryList View 
2/08 - UserList, GroupList, UserUpdate
2/10 - AddGroupList, updated UserUpdate
'''

from django.shortcuts import render
from rest_framework.response import Response
from rest_framework import status
from rest_framework import generics
from .models import User, Group, Entry, Notification, NotificationMessage
from .serializers import RegisterUserSerializer, EntrySerializer, UserSerializer, GroupSerializer, GroupsSerializer, UserUpdateSerializer, NotificationSerializer, NotificationMessageSerializer
from rest_framework.generics import ListAPIView, CreateAPIView
from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view

# RegisterUser view used for account registration
class RegisterUser(CreateAPIView):
    serializer_class = RegisterUserSerializer

# EntryList view used to send all Entry objects
class EntryList(ListAPIView):
    queryset = Entry.objects.all()
    serializer_class = EntrySerializer
# UserList used to send all User objects
class UserList(ListAPIView):
	queryset = User.objects.all()
	serializer_class = UserSerializer
# GroupList used to send all Group objects
class GroupList(ListAPIView):
	queryset = Group.objects.all()
	serializer_class = GroupsSerializer

class AddGroupList(ListAPIView):
	queryset = Group.objects.exclude(users=2)
	serializer_class = GroupsSerializer

# UserUpdate used to view and update user information (subscriptions)
class UserUpdate(generics.RetrieveUpdateAPIView):
	serializer_class = UserUpdateSerializer

	def get_object(self):
		id = self.kwargs['id']
		return get_object_or_404(User, id=id)
	
	def put(self, request, *args, **kwargs):
		return self.update(request, *args, **kwargs)

class UserNotificationList(generics.ListAPIView):
	serializer_class = NotificationMessageSerializer

	def get_queryset(self):
		queryset = []
		id = self.kwargs['id']
		print(id)
		if id is not None:
			notifmsgs = User.objects.get(id=id).messages.all()
			queryset = [notifmsg for notifmsg in notifmsgs if notifmsg.visible()]

			for notifmsg in queryset:
				NotificationMessage.objects.filter(id=notifmsg.id).update(viewed=True)
				print(notifmsg.viewed)
		return queryset

@api_view(['GET', 'PUT', 'DELETE'])
def notifmsg_detail(request, pk):
    """
    Retrieve, update or delete a code snippet.
    """
    try:
        notifmsg = NotificationMessage.objects.get(pk=pk)
    except Notification.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = NotificationMessageSerializer(notifmsg)
        return Response(serializer.data)

    elif request.method == 'PUT':
        serializer = NotificationMessageSerializer(notifmsg, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'DELETE':
        notifmsg.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


