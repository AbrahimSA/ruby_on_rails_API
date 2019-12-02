class EventsController < ApplicationController
    # before_action :set_event, only: [:show, :edit, :update, :destroy]
   #skip_before_action :verify_authenticity_token
   before_action :set_env
   
   
   # Erasing all the events`
   # The service should be able to erase all the events by the DELETE request at /erase
   #
   # == Parameters:
   #
   # == Returns:
   #   If completed The HTTP response code should be 200
   #   If error The HTTP response code should be 500
   def erase
         if Actor.destroy_all && Event.destroy_all && Repo.destroy_all
          #  head 200
          render json: {}, :status => 200
         else
          #  head 500
           render json: {}, :status => 500
         end  
    end
   
   
   # Adding new events`
   # The service should be able to add a new event by the POST request at /events
   #
   # == Parameters: JSON FORMAT
   #          {
   #          "id": 1,
   #          "type": "PushEvent",
   #          "actor": {
   #            "id": 1,
   #            "login": "cole",
   #            "avatar_url": "https://avatars.githubusercontent.com/u/1"
   #          },
   #          "repo": {
   #            "id": 1,
   #            "name": "cole/iste-et-v",
   #            "url": "https://api.github.com/repos/cole/iste-et-v"
   #          },
   #          "created_at":"2013-01-01 01:13:31"
   #        }
   # == Returns:
   #   If completed The HTTP response code should be 201
   #   If error The HTTP response code should be 500
     def create
       @json_parsed = params
       begin
           @event = Event.find(@json_parsed[:id])
       rescue => exception
           puts "Event not found"
       end
       if !@event.nil?
           render json: {}, :status => 400
       else
         #head 400
         puts "@json_parsed: #{@json_parsed}"
        #  if !@json_parsed[:id].nil? && !@json_parsed[:actor].nil?  && !@json_parsed[:actor][:id].nil? && !@json_parsed[:event].nil?  && !@json_parsed[:repo].nil?
            begin
              @actor = Actor.find(@json_parsed[:actor][:id])
            rescue => exception
              puts "Not found actor"
            end 
            # if @json_parsed[:id] == "1025337888"
            #   binding.pry
            # end
            if @actor.nil?
              @actor = Actor.new(@json_parsed.require(:actor).permit(:id, :login, :avatar_url))
              @actor.save     
            end
  
            @repo = Repo.new(@json_parsed.require(:repo).permit(:id, :name, :url))
            begin
              @repo.save
            rescue => exception
              puts "Repo already exist"
            end  
            @event = Event.new(event_params.merge(actor_id: @json_parsed[:actor][:id], repo_id: @json_parsed[:repo][:id]))   
            if @event.save  
                #head 201
                #render json => @event, :status => 201
                render json: JSON.parse( JSON.generate({})), :status => 201
            else
              #head 500
              render json: {}, :status => 500
            end  
          # end
        end
      end  
   
  
   # Returning all the events`
   # The service return the JSON array of all the events by the GET request at /events
   #
   # == Parameters:
   #
   # == Returns:
   #   If completed The HTTP response code should be 200
   #   If Event does not exist The HTTP response code should be 404
     # == Returns: JSON
    # [
    #   {
    #     "id":3822562012,
    #     "type":"PushEvent",
    #     "actor":{
    #       "id":2222918,
    #       "login":"xnguyen",
    #       "avatar_url":"https://avatars.com/2222918"
    #     },
    #     "repo":{
    #       "id":425512,
    #       "name":"cohenjacqueline/quam-autem-suscipit",
    #       "url":"https://github.com/cohenjacqueline/quam-autem-suscipit"
    #     },
    #     "created_at":"2015-07-15 15:13:31"
    #   }
    # ]
   def index
             begin
               @event =  Event.select("id, type, strftime('%Y-%m-%d %H:%M:%S', created_at) xpto,repo_id, actor_id").includes(:repo).includes(:actor).order('events.id asc')
             rescue => exception
               @event =  nil
             end 
             if !@event.nil? && @event.size > 0
                render json: (@event.to_json(except:[:actor_id, :repo_id],include:[ :actor, :repo]).gsub! 'xpto', 'created_at'), :status => 200
              # render json: @event.to_json(except:[:actor_id],include:[ :actor, repo: {except: [ :event_id]}]), :status => 200
             else
              json = @event.to_json
              # binding.pry
              render json: JSON.parse( JSON.generate([])), :status => 200
             end 
   end  
   
   # Method not requested
   # Returning the event records filtered by the Event ID`
   # The service return the JSON array of all the events 
   # by the actor ID by the GET request at /events/{eventID}. 
   #
   # == Parameters: eventID
   #
   # == Returns:
   #   If completed The HTTP response code should be 200
   #   If actor does not exist The HTTP response code should be 404
     # == Returns: JSON
    # [
    #   {
    #     "id":3822562012,
    #     "type":"PushEvent",
    #     "actor":{
    #       "id":2222918,
    #       "login":"xnguyen",
    #       "avatar_url":"https://avatars.com/2222918"
    #     },
    #     "repo":{
    #       "id":425512,
    #       "name":"cohenjacqueline/quam-autem-suscipit",
    #       "url":"https://github.com/cohenjacqueline/quam-autem-suscipit"
    #     },
    #     "created_at":"2015-07-15 15:13:31"
    #   }
    # ]
  #  def show
  #     if !params[:id].nil?
  #        begin
  #          @event =  Event.includes(:repo).includes(:actor).where(events: {id: params[:id]})
  #        rescue => exception
  #          @event =  nil
  #        end 
  #        if !@event.nil? && @event.size > 0
  #          render json: @event.to_json(except:[:actor_id],include:[ :actor, repo: {except: [ :event_id]} ])
  #        else
  #         head 404
  #        end
  #    else
  #      head 500
  #    end  
   
  #  end  
   
   
   private
   
       def set_env
         Event.inheritance_column = nil
       end  
   
       def event_params
        @json_parsed.permit(:id, :type, :created_at)
       end
   
   end
   