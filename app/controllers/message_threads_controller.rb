class MessageThreadsController < ApplicationController
  include MessageThreadsHelper

  before_action :authenticate_user!

  # GET /message_threads
  # GET /message_threads.json
  def index
    @page_title = "Messages"
    @message_threads = MessageThread.related_to(current_user)
    @message_thread = @message_threads.first
    if @message_thread
      @message_thread.mark_read!(current_user)
    end
  end

  # GET /message_threads/1
  # GET /message_threads/1.json
  def show
    @page_title = "Messages"
    @message_thread = MessageThread.find(params[:id])
    @message_thread.mark_read!(current_user)
    @message_threads = MessageThread.related_to(current_user)

    respond_to do |format|
      format.html { render :index }

      format.json do
        if @message_thread.related_to?(current_user)
          render json: thread_data(@message_thread)
        else
          render json: { error: "Access denied." }
        end
      end
    end
  end

  # POST /message_threads
  # POST /message_threads.json
  def create
    @page_title = "Messages"
    thread_params = message_thread_params

    if thread_params[:seller_id]
      thread_params[:buyer_id] = current_user.id
    elsif thread_params[:buyer_id]
      thread_params[:seller_id] = current_user.id
    end

    @message_thread = MessageThread.new(thread_params)

    respond_to do |format|
      if @message_thread.save
        format.html { redirect_to @message_thread, notice: 'Message thread was successfully created.' }
        format.json { render json: thread_data(@message_thread), status: :created, location: @message_thread }
      else
        format.html { render :new }
        format.json { render json: @message_thread.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @message_thread = MessageThread.find(params[:id])

    if @message_thread.deleted_by != current_user
      @message_thread.destroy!
    else
      @message_thread.deleted_by = current_user
      @message_thread.save!
    end

    redirect_to action: :index
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def message_thread_params
      params.require(:message_thread).permit(:seller_id, :buyer_id)
    end
end
