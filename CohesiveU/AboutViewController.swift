//
//  AboutViewController.swift
//  CohesiveU
//
//  Created by Sebastian Serrano on 2016-10-12.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var EULA: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

         EULA.text = "License \n\n Under this End User License Agreement (the \("Agreement")), Serranos Fund (the \("Vendor")) grants to the user (the \("Licensee")) a non-exclusive and non-transferable license (the \("License")) to use Cohesive (the \("Software")).\("Software") includes the executable Application and any related printed, electronic and online documentation and any other files that may accompany the product. Title, copyright, intellectual property rights and distribution rights of the Software remain exclusively with the Vendor. Intellectual property rights include the look and feel of the Software. This Agreement constitutes a license for use only and is not in any way a transfer of ownership rights to the Software. The rights and obligations of this Agreement are personal rights granted to the Licensee only. The Licensee may not transfer or assign any of the rights or obligations granted under this Agreement to any other person or legal entity. The Licensee may not make available the Software for use by one or more third parties. Failure to comply with any of the terms under the License section will be considered a material breach of this Agreement.\n\n Restrictions on use \n\n You shall use the Software strictly in accordance with the terms of the Related Agreements and shall not: (a) decompile, reverse engineer, disassemble, attempt to derive the source code of, or decrypt the Software; (b) violate any applicable laws, rules or regulations in connection with your access or use of the Software; (c) remove, alter or obscure any proprietary notice (including any notice of copyright or trademark) of Vendor or its affiliates, partners, suppliers or the licensors of the Software; (d) use the Software for any revenue generating endeavor, commercial enterprise, or other purpose for which it is not designed or intended; (e) [install, use or permit the Software to exist on more than one Mobile Device at a time or on any other mobile device or computer]; (f) [distribute the Software to multiple Mobile Devices];(g) use the Software to send automated queries to any website or to send any unsolicited commercial e-mail; or (h) use any proprietary information or interfaces of Vendor or other intellectual property of Vendor in the design, development, manufacture, licensing or distribution of any applications, accessories or devices for use with the Software. By using the Software, you represent and warrant that (a) you are 17 years of age or older and you agree to be bound by this Agreement; (b) if you are under 17 years of age, you have obtained verifiable consent from a parent or legal guardian; and (c) your use of the Software does not violate any applicable law or regulation. Your access to the Software may be terminated without warning if Vendor believes, in its sole discretion, that you are under the age of 17 years and have not obtained verifiable consent from a parent or legal guardian. If you are a parent or legal guardian and you provide your consent to your child’s use of the Software, you agree to be bound by this Agreement in respect to your child’s use of the Software. Any material that is deemed to be objectionable or abusive to any user will cause the termination of the license provided by the Vendor for the user who published such content. A report submitted by a user with the minimum requirements for such, will be reviewed within 24 hours and upon acceptance, such content will be removed as well as the user who published it.\n\n Limitation of Liability \n\n The Software is provided by the Vendor and accepted by the Licensee \("as is"). The Vendor will not be liable for any general, special, incidental or consequential damages including, but not limited to, loss of production, loss of profits, loss of revenue, loss of data, or any other business or economic disadvantage suffered by the Licensee arising out of the use or failure to use the Software. The Vendor makes no warranty expressed or implied regarding the fitness of the Software for a particular purpose or that the Software will be suitable or appropriate for the specific requirements of the Licensee. The Vendor does not warrant that use of the Software will be uninterrupted or error-free. The Licensee accepts that Software in general is prone to bugs and flaws within an acceptable level as determined in the industry. The Vendor may remedy any non-conforming Software by providing a refund of the purchase price or, at the Vendor's option, repair or replace any or all of the Software.\n\n Acceptance \n\n All terms, conditions and obligations of this Agreement will be deemed to be accepted by the Licensee \(("Acceptance")) on registration of the Software with the Vendor.\n\n  Miscellaneous \n\n This Agreement can only be modified in writing signed by both the Vendor and the Licensee. This Agreement does not create or imply any relationship in agency or partnership between the Vendor and the Licensee. Headings are inserted for the convenience of the parties only and are not to be considered when interpreting this Agreement. Words in the singular mean and include the plural and vice versa. Words in the masculine gender include the feminine gender and vice versa. Words in the neuter gender include the masculine gender and the feminine gender and vice versa. If any term, covenant, condition or provision of this Agreement is held by a court of competent jurisdiction to be invalid, void or unenforceable, it is the parties' intent that such provision be reduced in scope by the court only to the extent deemed necessary by that court to render the provision reasonable and enforceable and the remainder of the provisions of this Agreement will in no way be affected, impaired or invalidated as a result. This Agreement contains the entire agreement between the parties. All understandings have been included in this Agreement. Representations which may have been made by any party to this Agreement may in some way be inconsistent with this final written Agreement. All such statements are declared to be of no value in this Agreement. Only the written terms of this Agreement will bind the parties. This Agreement and the terms and conditions contained in this Agreement apply to and are binding upon the Vendor's successors and assigns.\n\n Termination \n\n This Agreement will be terminated and the License forfeited where the Licensee has failed to comply with any of the terms of this Agreement or is in breach of this Agreement. On termination of this Agreement for any reason, the Licensee will promptly destroy the Software or return the Software to the Vendor.\n\n For any inquiries contact: \n cohesiveios.v@gmail.com \n\n Visit us at: \n  cohesive.online \n\n Serranos Fund \n"
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func MenuTap(_ sender: AnyObject) {
        toggleMenu()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
