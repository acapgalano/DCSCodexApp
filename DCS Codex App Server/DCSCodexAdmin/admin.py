'''
This is a course requirement for CS 192 Software Engineering II under the supervision of Asst. Prof. Ma. Rowena C. Solamo 
of the Department of Computer Science, College of Engineering, University of the Philippines, Diliman for the AY 2019-2020.

Author: Anica Galano - 2016-01120 
File Created: 1/30/2020
Development Group: CS 192 Group 5 
Client Group: CS 192 Group 5
Purpose of the Software: To provide mobile access of the DCS Codex with the feature of notifications for reminders. 

Code History:
1/30 - all site registrations (User, Group, Entry)
'''

from django.contrib import admin
from .models import User, Group, Entry, Notification, NotificationMessage
# Registered models: 
admin.site.register(User)
admin.site.register(Group)
admin.site.register(Entry)
admin.site.register(Notification)
admin.site.register(NotificationMessage)