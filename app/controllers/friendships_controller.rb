class FriendshipsController < ApplicationController

  # POST /friendships
  # POST /friendships.json
  def create
    @friendship = current_user.friendships.build(:following_id => params[:following_id])

    respond_to do |format|
      if @friendship.save
        format.html { redirect_to user_profile_path(params[:following_id]), notice: 'Added successfully' }
        format.json { render :show, status: :created, location: @friendship }
      else
        format.html { redirect_to user_profile_path(params[:following_id]), alert: 'Unable to add user' }
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
      format.html { redirect_to user_profile_path(params[:following_id]), notice: 'Removed friend.' }
      format.json { head :no_content }
    end
  end

end
