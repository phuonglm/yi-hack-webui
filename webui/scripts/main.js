

google.charts.load("current", {packages:["timeline"]});
google.charts.setOnLoadCallback(drawChart);

$(document).ready(function(){
    if(!window.currentDate){
        window.currentDate = moment().startOf('day')
    }
    $('#date-selector').datepicker('setDate', window.currentDate._d);
    $('#date-selector').datepicker({
      autoclose: true
    }).on('changeDate', function(e){
        window.currentDate = moment(e.date).startOf('day');
        $("#date-dropdown").dropdown("toggle");
        drawChart();
    });
    $("#myModal").on('hide.bs.modal', function(){
        var myPlayer = videojs('cameraVideo');
        myPlayer.dispose();
    });

    $(".previous-btn").on('click', function(){
      var myPlayer = videojs('cameraVideo');
      myPlayer.playlist.previous()
    });
    $(".next-btn").on('click', function(){
      var myPlayer = videojs('cameraVideo');
      myPlayer.playlist.next()
    });

    $("#delete-btn").on('click', function(){
      var start = $("#cameraVideo").data("start");
      var end = $("#cameraVideo").data("end");
      var base = $("#cameraVideo").data("base");

      if (window.markStart && window.markEnd && window.markStart.isBefore(window.markEnd)){
        start = window.markStart;
        end = window.markEnd;
        window.markStart = undefined;
        window.markEnd = undefined;
      }

      var url = '/index.php?a=deletePlaylist&base=' + base +
          '&start=' + start +
          '&end=' + end;
      $.getJSON( url, function( data ) {
          $('#myModal').modal('hide');
          drawChart();
      });
    });
    $(".mark-start-btn").on('click', function(){
        if ($("#video_container video").length > 0){
            var myPlayer = videojs('cameraVideo');
            var source = myPlayer.currentSource();
            window.markStart = getDateFromMedia(source.src).add(window.time_offset / 1000 / 60, "minutes");
        }
    });

    $(".mark-end-btn").on('click', function(){
        if ($("#video_container video").length > 0){
            var myPlayer = videojs('cameraVideo');
            var source = myPlayer.currentSource();
            window.markEnd = getDateFromMedia(source.src).add(window.time_offset / 1000 / 60, "minutes");
        }
    });

});

function getDateFromMedia(url){
    return moment(url.match(/^.*\.mp4/)[0].slice(-25).substring(0,21),"YYYY[Y]MM[M]DD[D]HH[H]/mm[M]ss[S]");
}

function drawChart() {
   if(!window.currentDate){
        window.currentDate = moment().subtract(1, 'days').startOf('day')
   }

   var jsonData = $.ajax({
        url: "index.php?a=getData&d=" + window.currentDate,
        dataType: "json",
        async: false
    }).responseText;

    // Create our data table out of JSON data loaded from server.
    window.data = new google.visualization.DataTable(jsonData);

    // Instantiate and draw our chart, passing in some options.
    var chart = new google.visualization.Timeline(document.getElementById('chart_div'));
    var options = {
    };

    // Every time the table fires the "select" event, it should call your
    // selectHandler() function.
    google.visualization.events.addListener(chart, 'select', selectHandler);
    chart.draw(data, options);

    function selectHandler(e) {
        var click_row_id = chart.getSelection()[0]['row'];
        var startDate = moment(window.data.getValue(click_row_id, 1)).startOf('day');
        var clickedStart = moment(window.data.getValue(click_row_id, 1));
        var endDate = moment(window.data.getValue(click_row_id, 2)).endOf('day');
        var base = window.data.getValue(click_row_id, 0);

        var url = '/index.php?a=getPlaylist&type=json&base=' + base +
            '&start=' + startDate +
            '&end=' + endDate;
        $.getJSON( url, function( data ) {
            if ($("#video_container video").length > 0){
                var myPlayer = videojs('cameraVideo');
                myPlayer.dispose();
            }

            var title = clickedStart.format("D/M HH:mm");
            $('#pushModalLabel').html(title);
            var video = $('<video />', {
                'data-setup': '{"fluid": true}',
                class: 'col-xs-10 video-js vjs-default-skin vjs-big-play-centered',
                id: 'cameraVideo',
                controls: "" ,
                preload:"auto"
            });
            video.appendTo($('#video_container'));

            var myPlayer = videojs('cameraVideo');
            myPlayer.on('play', function () {
                $('#pushModalLabel').html(getDateFromMedia(myPlayer.currentSource().src).add(window.time_offset/1000/60, "minutes").format("D/M HH:mm"));
            });
            var playlist = [];
            var i = 0;

            $.each( data, function( key, val ) {
                item = {'sources': [ {'src': val, 'type': 'video/mp4'} ]};
                playlist.push(item);
                if(getDateFromMedia(val).add(window.time_offset/1000/60, "minutes").isBefore(clickedStart)){
                    i++;
                }
            });

            $("#cameraVideo").data("start", startDate._i);
            $("#cameraVideo").data("end", endDate._i);
            $("#cameraVideo").data("base", base);


            $('#myModal').bind('keydown',function(e){
                var keycode = e.keyCode;
                var myPlayer = videojs('cameraVideo');
                if (keycode == 39) {
                    myPlayer.playlist.next();
                } else if (keycode == 37) {
                    myPlayer.playlist.previous();
                } else if (keycode == 46) {
                    $("#delete-btn").trigger('click');
                }
            });

            $("#pushModalLabel").swipe({
                'hold': function(event, target) {
                    if (navigator && navigator.clipboard && navigator.clipboard.writeText){
                        navigator.clipboard.writeText(myPlayer.currentSource().src);
                    }
                }
            });

            $('#video_container video').swipe({
                swipe:function(event, direction, distance, duration, fingerCount, fingerData) {
                    if (direction === 'left') {
                        myPlayer.playlist.next();
                    } else if (direction === 'right') {
                        myPlayer.playlist.previous();
                    }
                    return true;
                },
                doubleTab: function(event, target){
                    myPlayer.requestFullscreen();
                    return true;
                }
            });

            $('#video_container video').bind('dblclick', function() { myPlayer.requestFullscreen(); });
            myPlayer.playlist(playlist, 0);
            myPlayer.playlist.autoadvance(0);

            myPlayer.playlist.currentItem(i);

            $(".google-visualization-tooltip").hide()
            $('#myModal').modal('show');
            myPlayer.play();
        });
    }


}
