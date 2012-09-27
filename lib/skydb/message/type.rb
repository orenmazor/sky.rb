class SkyDB
  class Message
    class Type
      ########################################################################
      #
      # Constants
      #
      ########################################################################
      
      ##################################
      # Message Types
      ##################################

      EVENT     = 0x10000
      PATH      = 0x20000
      ACTION    = 0x30000
      PROPERTY  = 0x40000

      ADD       = 0x00001
      UPD       = 0x00002
      DEL       = 0x00003
      GET       = 0x00004
      ALL       = 0x00005
      EACH      = 0x00006
      

      ##################################
      # Action Message Types
      ##################################

      AADD = (ACTION | ADD)
      AGET = (ACTION | GET)
      AALL = (ACTION | ALL)


      ##################################
      # Property Message Types
      ##################################

      PADD = (PROPERTY | ADD)
      PGET = (PROPERTY | GET)
      PALL = (PROPERTY | ALL)


      ##################################
      # Event Message Types
      ##################################

      EADD = (EVENT | ADD)


      ##################################
      # Path Message Types
      ##################################

      PEACH = (PATH | EACH)
      
    end
  end
end