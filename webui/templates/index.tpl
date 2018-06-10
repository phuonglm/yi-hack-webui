<html>
  <head>
    <title>{$doc_title}</title>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="scripts/node_modules/bootstrap/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="scripts/node_modules/bootstrap/dist/css/bootstrap-theme.min.css">
    <link rel="stylesheet" href="scripts/node_modules/font-awesome/css/font-awesome.min.css">
    <link rel="stylesheet" href="scripts/node_modules/bootstrap-datepicker/dist/css/bootstrap-datepicker3.min.css">
    <link href="scripts/node_modules/video.js/dist/video-js.css" rel="stylesheet">

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="scripts/node_modules/bootstrap/dist/js/bootstrap.min.js"></script>
    <script src="scripts/node_modules/bootstrap-autohidingnavbar/dist/jquery.bootstrap-autohidingnavbar.min.js"></script>
    <!-- If you'd like to support IE8 -->
    <script src="scripts/node_modules/videojs-ie8/dist/videojs-ie8.min.js"></script>
    <!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>

    <script type="text/javascript" src="scripts/node_modules/moment/min/moment.min.js"></script>
    <script src="scripts/node_modules/bootstrap-datepicker/dist/js/bootstrap-datepicker.min.js"></script>

    <script src="scripts/node_modules/video.js/dist/video.js"></script>
    <script src="scripts/node_modules/videojs-playlist/dist/videojs-playlist.min.js"></script>
  </head>

  <body>
    <nav class="navbar navbar-default">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#" style="font-size: 2em;">Camera Visualizer</a>
        </div>
        <div class="collapse navbar-collapse" id="navbar">
          <ul class="nav navbar-nav navbar-right">
            <li class="dropdown">
                <a href="#" class="dropdown-toggle fa fa-video-camera fa-2x" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"> {$device_info['device_name']}<span class="caret"></span></a>
                <ul class="dropdown-menu">
                  {section name=id loop=$devices}
                  <li><a href="#">{$devices[id]}</a></li>
                  {/section}
                </ul>
            </li>
            <li class="dropdown">
                 <a href="#" id="date-dropdown" class="dropdown-toggle fa fa-calendar fa-2x" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"> {$time_range} <span class="caret"></span></a>
                <ul class="dropdown-menu">
                  <li>
                      <div id="date-selector"></div>
                  </li>
                </ul>
            </li>
          </ul>
        </div>
      </div>
    </nav>
    <div class="container">
      <div class="row">
        <div class="col-xs-12">
        </div>
      </div>
      <div class="row">
        <div class="col-xs-12" style="visibility: hidden;">
          <a name="end" href="#end">end</a>
        </div>
      </div>
    </div>
    <!--Div that will hold the pie chart-->
    <div id="chart_div"></div>
    {include file="player.tpl"}

    <script src="scripts/main.js"></script>
  </body>
</html>