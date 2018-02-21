

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

    $(".previous-btn").click(function(){
      var myPlayer = videojs('cameraVideo');
      myPlayer.playlist.previous();
    });
    $(".next-btn").click(function(){
      var myPlayer = videojs('cameraVideo');
      myPlayer.playlist.next();
    });

    $("#delete-btn").click(function(){
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
    $(".mark-start-btn").click(function(){
        if ($("#video_container video").length > 0){
            var myPlayer = videojs('cameraVideo');
            var source = myPlayer.currentSource();
            window.markStart = getDateFromMedia(videojs('cameraVideo').currentSource().src);
        }
    });

    $(".mark-end-btn").click(function(){
        if ($("#video_container video").length > 0){
            var myPlayer = videojs('cameraVideo');
            var source = myPlayer.currentSource();
            window.markEnd = getDateFromMedia(videojs('cameraVideo').currentSource().src);
        }
    });

    $(".reload-btn").click(function(){
        window.location.href = "/";
    });
});

function getDateFromMedia(url){
    return moment(url.substring(44,65),"YYYY[Y]MM[M]DD[D]HH[H]/mm[M]ss[S]");
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
        var clickedData = window.data.og[chart.getSelection()[0]['row']]['c'];
        var clickedStart = moment(clickedData[1]['v']);
        var clickedEnd = moment(clickedData[2]['v']);
        var base = clickedData[0]['v'];

        var url = '/index.php?a=getPlaylist&type=json&base=' + base +
            '&start=' + moment(clickedData[1]['v']).startOf('day') +
            '&end=' + moment(clickedData[2]['v']).endOf('day');
        $.getJSON( url, function( data ) {
            if ($("#video_container video").length > 0){
                var myPlayer = videojs('cameraVideo');
                myPlayer.dispose();
            }

            var title = clickedStart.format("D/M HH:mm") + " ~> " + clickedEnd.format("D/M HH:mm");
            $('#pushModalLable').html(title);
            var video = $('<video />', {
                'data-setup': '{"fluid": true}',
                class: 'col-xs-10 video-js vjs-default-skin vjs-big-play-centered',
                id: 'cameraVideo',
                controls: "" ,
                preload:"auto"
            });
            video.appendTo($('#video_container'));

            var myPlayer = videojs('cameraVideo');
            var playlist = [];
            var i = 0;

            $.each( data, function( key, val ) {
                item = {'sources': [ {'src': val, 'type': 'video/mp4'} ]};
                playlist.push(item);
                if(getDateFromMedia(val).isBefore(clickedStart)){
                    i++;
                }
            });

            $("#cameraVideo").data("start", clickedStart._i);
            $("#cameraVideo").data("end", clickedEnd._i);
            $("#cameraVideo").data("base", base);

            myPlayer.on('keydown', function(e){
                var keycode = e.keyCode;
                if (keycode == 39) {
                    myPlayer.playlist.next();
                } else if (keycode == 37) {
                    myPlayer.playlist.previous();
                } else if (keycode == 46) {
                    $("#delete-btn").trigger('click');
                }
            });

            myPlayer.playlist(playlist, 0);
            myPlayer.playlist.autoadvance(0);

            myPlayer.playlist.currentItem(i);

            $(".google-visualization-tooltip").hide()
            $('#myModal').modal('show');
            myPlayer.play();
        });
    }


}

