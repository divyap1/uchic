class NotificationsController < ApplicationController

    # DELETE /friendships/1
    # DELETE /friendships/1.json
    def destroy
      @notification = current_user.notifications.where(:id => params[:id]).first
      @notification.destroy

      respond_to do |format|
        format.html { redirect_to user_activity_feed_path(params[:following_id]), notice: 'Removed notification.' }
        format.json { head :no_content }
      end
    end

  end
