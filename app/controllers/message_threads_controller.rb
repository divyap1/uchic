class MessageThreadsController < ApplicationController
  before_action :set_message_thread, only: [:show, :edit, :update, :destroy]

  # GET /message_threads
  # GET /message_threads.json
  def index
    @message_threads = MessageThread.all
  end

  # GET /message_threads/1
  # GET /message_threads/1.json
  def show
  end

  # GET /message_threads/new
  def new
    @message_thread = MessageThread.new
  end

  # GET /message_threads/1/edit
  def edit
  end

  # POST /message_threads
  # POST /message_threads.json
  def create
    @message_thread = MessageThread.new(message_thread_params)

    respond_to do |format|
      if @message_thread.save
        format.html { redirect_to @message_thread, notice: 'Message thread was successfully created.' }
        format.json { render :show, status: :created, location: @message_thread }
      else
        format.html { render :new }
        format.json { render json: @message_thread.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /message_threads/1
  # PATCH/PUT /message_threads/1.json
  def update
    respond_to do |format|
      if @message_thread.update(message_thread_params)
        format.html { redirect_to @message_thread, notice: 'Message thread was successfully updated.' }
        format.json { render :show, status: :ok, location: @message_thread }
      else
        format.html { render :edit }
        format.json { render json: @message_thread.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /message_threads/1
  # DELETE /message_threads/1.json
  def destroy
    @message_thread.destroy
    respond_to do |format|
      format.html { redirect_to message_threads_url, notice: 'Message thread was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message_thread
      @message_thread = MessageThread.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_thread_params
      params.require(:message_thread).permit(:commission_id, :seller_id, :buyer_id)
    end
end
