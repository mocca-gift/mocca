class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  
  before_action do
    PERMIT_ADDRESSES = ['127.0.0.1', '::1', '115.165.80.15' , ENV['MY_IP_ADDRESS'], ENV['MY_SUB_IP_ADDRESS'], ENV['H_IP_ADDRESS']].freeze

    unless PERMIT_ADDRESSES.include?(request.remote_ip)
      render text: 'Service Unavailable', status: 503
    end
  end
  
  layout 'home'

  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.order(:id)
   
    @qYes = Hash.new(0)
    @qNo  = Hash.new(0)
    
    @questions.each do |question|
      yes=Answer.where(:question_id => question.id).find_by_ansid(1) || Answer.create(question_id: question.id , ansid: 1 , count: 0)
      no =Answer.where(:question_id => question.id).find_by_ansid(2) || Answer.create(question_id: question.id , ansid: 2 , count: 0)
      @qYes[question]= yes.count
      @qNo[question]=  no.count 
    end

  end

  # GET /questions/1
  # GET /questions/1.json
  def show
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: 'Question was successfully created.' }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:body)
    end
end
