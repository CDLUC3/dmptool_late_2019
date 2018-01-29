<%= _('About') %>
===============

<%= _("Scholarly researchers today are increasingly required to engage in a range of data management activities to comply with institutional policies, or as a precondition for publication or grant funding. To aid researchers in creating effective Data Management Plans (DMPs), we have worked closely with funders and universities to develop an online application: DMPRoadmap. The tool provides detailed guidance and links to general and institutional resources and walks a researcher through the process of generating a comprehensive plan tailored to specific DMP requirements.") %>

### <%= _('DMP Background') %>
         
<%= _("The Digital Curation Centre and UC3 team at the California Digital Library have developed and delivered tools for data management planning since the advent of open data policies in 2011. ")%>
          <%= link_to "DMPonline", "https://DMPonline.dcc.ac.uk/" %><%=_(" (DCC-UK) and ") %><%= link_to "DMPTool", "https://dmptool.org/" %>
          <%= _("(CDL-US) are now established in our national contexts as the resource for researchers seeking guidance in creating DMPs. We have worked together from the outset to share experiences, but with the explosion of interest in both of our tools across the globe we formalized our partnership to co-develop and maintain a single open-source platform for DMPs. By working together we can extend our reach, keep costs down, and move best practices forward, allowing us to participate in a truly global open science ecosystem.") %>

<%= _("The new platform will be separate from the services each of our teams runs on top of it. Our shared goal: provide a combined DMPRoadmap platform as a core infrastructure for DMPs. Future enhancements will focus on making DMPs machine actionable so please continue sharing your use cases.") %>

<%= _("We invite you to peruse the DMPRoadmap GitHub wiki to learn how to ")%><%= link_to( "get involved", "https://github.com/DMPRoadmap/roadmap/wiki/get-involved", target: '_blank', id: "get involved" ) %><%= _(" in the project. You can also report bugs and request new features via ") %><a href="https://github.com/DMPRoadmap/roadmap/issues" target='_blank'>
          <%= _('GitHub Issues') %></a>

### <%= _('Getting Started') %>

<%= _("If you have an account please sign in and start creating or editing your DMP.") %>
<%= _("If you do not have a DMPTool account, click on") %> <a href="<%= root_path %>"><%= _('Sign up') %></a> <%= _("on the homepage.") %>

<%= _("Please visit the") %> <a href="<%= help_path %>"><%= _('Help') %></a> <%= _("page for guidance.") %>

### <%= _("Customising for your Organisation") %>

<%= _("Organisations can customise the tool to highlight local requirements, resources, and services. Institutional templates can be added to address local DMP requirements, and additional sections and questions can be included in funder templates. Users from participating organisations that configure the tool for single sign-on can log in with their own institutional accounts.") %>