QB-CORE Mail system
(Old script, I prob wont fix any issues or fix the UI design..)
</br>
</br>
Ever wanetd to send post to eachother?
</br>
Then this is the perfect script for you!
</br>
</br>
You can send all players a mail by using the envelope to write a litter.
</br>
Use the envelope to open up the letter and start writing.
</br>
Use **Firstname.Lastname@email.com** as the receiver.
</br>
Click on **Submit** to write the letter.
</br>
Go to one of te set post office locations and use the written envelope to send it.
</br>
</br>
To view all your mails, go to one of the locations or set mailbox props (target).
</br>
</br>
You will need to add an **envelope** item in your shared items.
</br>
<code>	['envelop'] 			 		 = {['name'] = 'envelop', 			  			['label'] = 'Envelop', 					['weight'] = 0, 		['type'] = 'item', 		['image'] = 'Envelop.png',          	['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},</code>
</br>
</br>
Add this to **Server > Player.lua**
</br>
<code>PlayerData.metadata['email'] =  PlayerData.metadata['email'] or string.lower(noSpace(tostring(PlayerData.charinfo.firstname))..'.'..noSpace(tostring(PlayerData.charinfo.lastname))..'@email.com')</code>

</br>

Import all the **SQL** files
