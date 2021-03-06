<!-- Modal -->
<div class="modal fade modal-fullscreen" id="myModal" tabindex="-1" role="dialog" aria-labelledby="modalBottomLabel">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content" id="video-player-modal" style="height: auto;">
            <div class="modal-header">
              <h4 class="modal-title" id="pushModalLabel"></h4>
              <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
            <div class="modal-body">
                <div class="col-12" style="padding-bottom: 20px;">
                    <div class="col-12" id="video_container"></div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="previous-btn btn btn-secondary"><</button>
                <button type="button" class="next-btn btn btn-secondary">></button>
                <button type="button" class="mark-start-btn btn btn-secondary" alt="Select start point to delete">S-</button>
                <button type="button" class="mark-end-btn btn btn-secondary" alt="Select end point to delete">S+</button>
                <button type="button" id="delete-btn" class="submit-button push-btn btn btn-danger">Delete</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
