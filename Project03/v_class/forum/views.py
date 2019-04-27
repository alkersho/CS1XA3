from django.http import HttpResponse
from django.shortcuts import render, redirect
import json
from forum.models import Topic, Post, Comment
from people.models import Person


def main(request):
    if request.method == "POST":
        post = json.loads(request.body)
        if "newTopic" in post.keys():
            new_topic = post['newTopic']
            topic = Topic(name=new_topic)
            topic.save()
            topics = [{"id": x.pk,
                       "name": x.name}
                      for x in Topic.objects.all()]
            return HttpResponse(json.dumps(topics))
        # deleting topics, never actually implemented client side
        # probably will never implement this feature, as a design choice
        if "topicID" in post.keys():
            tID = post['topicID']
            try:
                Topic.objects.get(pk=tID).delete()
            except Exception:
                return HttpResponse("server Error")
            return HttpResponse("")
        # searching for posts by title
        # a more complex algorithm can be employed here, but nah. Maybe later
        name = post['postName']
        posts = [
            {"title": x.title,
             "id": x.id}
            for x in Post.objects.filter(title__contains=name)
        ]
        return HttpResponse(json.dumps(posts))
    # loads all topics when loading the forum page
    posts = [
        {"title": x.title,
         "id": x.id}
        for x in Post.objects.all()
    ]
    return render(request, "forum/forum.html", context={"posts": posts})

# loads post, might implement delete post here
def view_post(request, post_id):
    post = Post.objects.get(pk=post_id)
    context = {
        "title": post.title,
        "body": post.body,
        "post_id": post_id,
        "canEdit": post.owner.user == request.user,
    }
    return render(request, "forum/post.html", context=context)


def create_post(request):
    if not request.user.is_authenticated:
        return redirect("people:login")
    if request.method == "POST":
        post = json.loads(request.body)
        title = post['title']
        body = post['body']
        topic = Topic.objects.get(pk=int(post['topic']))
        user = Person.objects.get(user=request.user)
        try:
            new_post = Post(title=title, body=body, owner=user, topic=topic)
            new_post.save()
        except Exception:
            return HttpResponse("Failed server error.")
        return HttpResponse("")
    topics = [{"id": x.pk,
               "name": x.name}
              for x in Topic.objects.all()]
    return render(request, "forum/create_post.html",
                  context={"topics": topics})


def comment(request, post_id_string, parent_id_string):
    parent_id = int(parent_id_string)
    post_id = int(post_id_string)
    if parent_id < 0:
        # posting parent comments
        if request.method == "POST":
            if not request.user.is_authenticated:
                return HttpResponse("You need to be logged in!")
            post = json.loads(request.body)
            c = Comment(body=post['body'],
                        owner=Person.objects.get(user=request.user),
                        post=Post.objects.get(pk=post_id))
            c.save()
            return HttpResponse("")
        # getting all comments
        if request.method == "GET":
            comments = [{"postID": post_id,
                         "commentID": x.pk,
                         "body": x.body,
                         "children": x.get_children()}
                        for x in Comment.objects.filter(
                                post__pk=post_id).filter(parent_comment=None)]
            return HttpResponse(json.dumps(comments))
        return HttpResponse("This is a parent comment")
    # posting sub comments
    if request.method == "POST":
        if request.user.is_authenticated:
            post = json.loads(request.body)
            c = Comment(body=post['body'],
                        owner=Person.objects.get(user=request.user),
                        parent_comment=Comment.objects.get(pk=parent_id),
                        post=Post.objects.get(pk=post_id))
            c.save()
            return HttpResponse("")
        else:
            return HttpResponse("You need to be logged in!")
    # for testing purposes, users should never access this site
    return HttpResponse("parent comment id: {}, post id: {}".format(
        parent_id, post_id))


def edit_posts(request, post_id):
    if request.body:
        postRequest = json.loads(request.body)
        post = Post.objects.get(pk=post_id)
        post.body = postRequest['body']
        post.save()
        return HttpResponse("")
    post = Post.objects.get(pk=post_id)
    title = post.title
    body = post.body
    context = {"id": post_id,
               "title": title,
               "body": body}
    return render(request, "forum/edit_post.html", context=context)
