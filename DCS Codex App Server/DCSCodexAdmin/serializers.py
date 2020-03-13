'''
This is a course requirement for CS 192 Software Engineering II under the supervision of Asst. Prof. Ma. Rowena C. Solamo 
of the Department of Computer Science, College of Engineering, University of the Philippines, Diliman for the AY 2019-2020.

Author: Anica Galano - 2016-01120 and Ken Tabagan - 2017-00897
File Created: 1/31/2020
Development Group: CS 192 Group 5 
Client Group: CS 192 Group 5
Purpose of the Software: To provide mobile access of the DCS Codex with the feature of notifications for reminders. 

Code History:
1/30 - RegisteredUserSerializer 
1/31 - EntrySerializer
2/08 - UserSerializer, GroupSerializer, UserUpdateSerializer
2/10 - Updated UserUpdateSerializer, GroupsSerializer
2/22 - Added NotificationSerializer
2/26 - Edits to Notification Serializer and add NotificationMessageSerializer
'''
from django.shortcuts import render, redirect, get_object_or_404
from .models import User, Group, Entry, Notification, NotificationMessage, NotificationRequest
from rest_framework import serializers # Serializers - converts JSON to python object and vice-versa

# RegisterUserSerializer serializes requests to create a new user account
class RegisterUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'groups']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create(
            username=validated_data['username'],
            email=validated_data['email'],
        )
        user.set_password(validated_data['password'])
        user.save() # Creates new user object to be registered into the system
        user.groups.set(validated_data['groups'])
        return user

# Entry Serializer unserializes requests for the list of entries 
class EntrySerializer(serializers.ModelSerializer):
    group = serializers.StringRelatedField()
    class Meta:
        model = Entry 
        fields = ['date','name', 'info', 'group']

"""class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Entry
        fields = [ 'info', 'date_to_send']"""

# User Serializer to serialize User data
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'email', 'groups')

#Group Serializer to serialize Group Data
class GroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = Group
        fields = ('id', 'name', 'users')

class GroupsSerializer(serializers.ModelSerializer): # nested serialization for Group.name as String in UserUpdateSerializer
    class Meta:
        model = Group
        fields = ('name',)

#Unserializes requests for update on user information (particularly subscriptions)
class UserUpdateSerializer(serializers.ModelSerializer):
    groups = GroupsSerializer(many=True)
    class Meta:
        model = User
        fields = ('id', 'email', 'groups')

    def update(self, instance, validated_data):
        instance.id = validated_data.get('id', instance.id)
        temp = []
        for group in validated_data['groups']:
            print(group['name'])
            temp.append(Group.objects.get(name=group['name'])) # looks for id of Group.name to be saved to User instance
        instance.save()
        instance.groups.set(temp)
        return instance
        
class NotificationSerializer(serializers.ModelSerializer):
    group = serializers.StringRelatedField()
    class Meta:
        model = Notification
        fields = [ 'title','info','group', 'date_to_send']

class NotificationMessageSerializer(serializers.ModelSerializer):
    notification = NotificationSerializer()

    class Meta: 
        model = NotificationMessage
        fields = ['id','notification', 'user', 'viewed']

    def update(self, instance, validated_data):
        instance.notification = validated_data.get('notification', instance.notification)
        instance.user = validated_data.get('user',instance.user),
        instance.viewed = True
        return instance 

class NotificationRequestSerializer(serializers.ModelSerializer):
    group = serializers.StringRelatedField()
    class Meta:
        model = NotificationRequest
        fields = ['user', 'group', 'title', 'message', 'purpose', 'date_to_send', 'approved', 'viewed']

class NotificationRequestCreateSerializer(serializers.ModelSerializer):
    group = serializers.SlugRelatedField(
        queryset=Group.objects.all(),
        many=False,
        read_only=False,
        slug_field='name'
     )
    class Meta:
        model = NotificationRequest
        fields = ['user', 'group', 'title', 'message', 'purpose', 'date_to_send','approved', 'viewed']
    