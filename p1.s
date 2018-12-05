.data
outStrFormat: .asciz "testing: %s\n"
outCharFormat: .asciz "%c\n"
str:  .space 100 
outformat:     .asciz "%c"       
stringread:     .asciz "%s" 
lengthread:     .asciz "%d"     
prompt: .asciz "input a string:\n"  
length: .asciz "the length is: %d\n"  
lenbuffer: .space 8
flush:          .asciz "\n"  
nomessage: .asciz "Palindrome: False\n"
yesmessage: .asciz "Palindrome: True\n"
outmessage: .space 100

.text
.global main

main:       #prompts user to input a string
            ldr x0, =prompt
            ldr x1, =str
            bl printf
                  
            #Reads in a string from the user
            ldr x0, =stringread
            ldr x1, =str
            bl scanf


            #loads string in, branches to loop to get the length of string
            #x9 length register
            #x11 string register
            ldr x11, =str
            ldr x2, =lenbuffer
            ldr x2, [x2, #0]
            bl loop

            #x19 register holds the length of the string
            mov x19,x2

            #prints the length of the string
            ldr x0, =length
            mov x1,x2
            bl printf          
           

            #x1 = thestring
            #x18 = thestring (for the comparison)
            #x0 is the length minus 1
            #x2 is the index for the reverse
            ldr x1, =str
            mov x18,x1
            mov x0, x19
            sub x0, x0, #1
            ldr x1, =str 
            mov x2, #0

            #x20 is the index for the comparioson
            mov x20, #0
            bl reverse

            ldr x0, =yesmessage
            ldr x1, =outmessage
            bl printf

            

            #Flush the stdout buffer
            ldr x0, =flush
            bl printf


            #Exit the program
            b exit



loop:       ldr x11, = str
            ldrb w1, [x11,x2]
            add x2,x2,#1 
          
            cbnz w1, loop 
            sub x2, x2, #1

            br x30
    


reverse:    #In reverse we want to maintain
            #x0 is length-1
            #x1 is memory location where string is
            #x2 is index

            subs x3, x2, x0

            #If we haven't reached the last index, recurse
            b.lt recurse

base:       #We've reached the end of the string. Print!
            ldr x0, =outformat
        
            #We need to keep x1 around because that's the string address!
            #Also bl will overwrite return address, so store that too
            stp x30, x1, [sp, #-16]!
            ldrb w1, [x1, x2]
            ldrb w3, [x18,x20]
            cmp w1,w3
            bne notpalindrome
            add x20, x20, #1
            #printing the last character in the string, first
            ldp x30, x1, [sp], #16

            #Go back and start executing at the return
            #address that we stored 
            br x30

recurse:    #First we store the frame pointer(x29) and 
            #link register(x30)
            sub sp, sp, #16
            str x29, [sp, #0]
            str x30, [sp, #8]

            #Move our frame pointer
            add x29, sp, #8

            #Make room for the index on the stack
            sub sp, sp, #16

            #Store it with respect to the frame pointer
            str x2, [x29, #-16]

            add x2, x2, #1 

            #Branch and link to original function. 
            bl reverse

            #Back from other recursion, so load in our index
end_rec:    ldr x2, [x29, #-16]

            #Print the char!
            stp x30, x1, [sp, #-16]!
            ldr x0, =outformat
            ldrb w1, [x1, x2]
            ldrb w3, [x18,x20]
            cmp w1,w3
            bne notpalindrome
            add x20, x20, #1
            ldp x30, x1, [sp], #16

            #Clear off stack space used to hold index
            add sp, sp, #16

            #Load in fp and lr
            ldr x29, [sp, #0]
            ldr x30, [sp, #8]
            
            #Clear off the stack space used to hold fp and lr
            add sp, sp, #16

            #Return to correct location in execution
            br x30

comparison: 

            br x30

notpalindrome:
            #prompts user to input a string
            ldr x0, =nomessage
            ldr x1, =outmessage
            bl printf
            
            ldr x0, =flush
            bl printf


exit:       mov x0, #0
            mov x8, #93
            svc #0
