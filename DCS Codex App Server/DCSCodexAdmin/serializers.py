'''
This is a course requirement for CS 192 Software Engineering II under the supervision of Asst. Prof. Ma. Rowena C. Solamo 
of the Department of Computer Science, College of Engineering, University of the Philippines, Diliman for the AY 2019-2020.

Author: Anica Galano - 2016-01120 
File Created: 1/31/2020
Development Group: CS 192 Group 5 
Client Group: CS 192 Group 5
Purpose of the Software: To provide mobile access of the DCS Codex with the feature of notifications for reminders. 

Code History:
1/30 - RegisteredUserSerializer 
1/31 - EntrySerializer
'''

from .models import User, Group, Entry
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

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'email', 'groups')

class GroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = Group
        fields = ('id', 'name', 'users')

class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'email', 'groups')

    def update(self, instance, validated_data):
        instance.id = validated_data.get('id', instance.id)
        instance.save()
        instance.groups.set(validated_data['groups'])
        return instance
