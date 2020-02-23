'''
This is a course requirement for CS 192 Software Engineering II under the supervision of Asst. Prof. Ma. Rowena C. Solamo 
of the Department of Computer Science, College of Engineering, University of the Philippines, Diliman for the AY 2019-2020.

Author: Anica Galano - 2016-01120 and Ken Tabagan - 2017-00897
File Created: 1/30/2020
Development Group: CS 192 Group 5 
Client Group: CS 192 Group 5
Purpose of the Software: To provide mobile access of the DCS Codex with the feature of notifications for reminders. 

Code Histroy: 
1/30 - User model, Group model, Entry model 
1/31 - Added __str__ method for Group model
2/08 - Added groups attribute to User to reflect many-to-many relationship with group
'''

from django.db import models
from django.contrib.auth.models import AbstractUser

class Group(models.Model):
	 name = models.CharField(max_length=50)
	 def __str__(self):
	 	return self.name

class User(AbstractUser):
     email = models.EmailField(unique=True) # Override Django user by making email unique
     groups = models.ManyToManyField(Group, related_name='users') #refers to model Group

class Entry(models.Model):
     date = models.DateField()
     name = models.CharField(max_length=50)
     info = models.TextField(max_length=250)
     group = models.ForeignKey('Group', on_delete=models.CASCADE) # Each entry is related to a Group

class Notification(models.Model):
	 #group = models.ForeignKey('Group', on_delete=models.CASCADE, blank=True, null=True)
	 info = models.TextField(max_length=250)
	 date_to_send = models.DateTimeField()
