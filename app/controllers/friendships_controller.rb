class FriendshipsController < ApplicationController

  # POST /friendships
  # POST /friendships.json
  def create
    @friendship = current_user.friendships.build(:following_id => params[:following_id])

    respond_to do |format|
      if @friendship.save
        format.html { redirect_to user_profile_path(params[:following_id]), notice: 'You are now following this user' }
        format.json { render :show, status: :created, location: @friendship }
        User.find_by_id(params[:following_id]).notifications.create(about_user_id: current_user.id, state: "new follower");
      else
        format.html { redirect_to user_profile_path(params[:following_id]), alert: 'Unable to follow user' }
        format.json { render :show, status: :created, status: :unprocessable_entity }
      end
    end

  end

  # DELETE /friendships/1
  # DELETE /friendships/1.json
  def destroy
    @friendship = current_user.friendships.where(:following_id => params[:id]).first
    @friendship.destroy

    respond_to do |format|
      format.html { redirect_to user_profile_path(params[:following_id]), notice: 'You no longer follow this user.' }
      format.json { head :no_content }
    end
  end

end
