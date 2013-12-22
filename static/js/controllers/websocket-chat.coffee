

ws = null    
chatApp = angular.module "chatApp", []

chatApp.factory "ChatService", ()->
    service = {}
    service.connect = () ->
        return if service.ws

        ws = new WebSocket "ws://#{location.host}/api"
        ws.onmessage = (event) ->
            service.callback(event)

        service.ws = ws
    
    service.subscribe = (callback) ->
        service.callback = callback

    return service
    
chatApp.controller "Ctrl", ['$scope', 'ChatService', ($scope, ChatService) ->
    $scope.templateUrl = "/static/partials/chat.html"
    $scope.messages = []
    $scope.members = {}

    ChatService.connect()
    ChatService.subscribe (event) ->
        data = JSON.parse event.data
        console.log 'data', data
        switch data.type
            when 'online'
                for msg in data.messages
                    $scope.members[msg.cid] = {'datetime': msg.datetime}
            when 'offline'
                for msg in data.messages
                    delete $scope.members[msg.cid]
            when 'message'
                for msg in data.messages
                    $scope.messages.push msg
                console.log '$scope.messages:', $scope.messages, data.messages
                $('#logs').animate {scrollTop: $('#logs')[0].scrollHeight}, "300", "swing"

        $scope.$apply()
        console.log '$scope.members:', $scope.members
    return 'ok'
]

        
$('form').submit (event) ->
    msg = $('#message-input').val()
    if msg.length > 0
        ws.send msg
        $('#message-input').val ""
    return false