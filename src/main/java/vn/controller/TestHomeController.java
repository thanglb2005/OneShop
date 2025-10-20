package vn.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import vn.entity.User;

import java.util.ArrayList;
import java.util.HashMap;

@Controller
public class TestHomeController {

    @GetMapping("/home-test")
    public String testHome(HttpSession session, Model model) {
        try {
            User user = (User) session.getAttribute("user");
            model.addAttribute("user", user);
            
            // Add empty collections to avoid template errors
            model.addAttribute("categories", new ArrayList<>());
            model.addAttribute("shopList", new ArrayList<>());
            model.addAttribute("productList", new ArrayList<>());
            model.addAttribute("bestSaleProduct20", new ArrayList<>());
            model.addAttribute("coutnProductByCategory", new ArrayList<>());
            model.addAttribute("avgMap", new HashMap<>());
            model.addAttribute("totalCartItems", 0);
            model.addAttribute("selectedShopId", null);
            
            return "web/home";
        } catch (Exception e) {
            model.addAttribute("error", "Error: " + e.getMessage());
            model.addAttribute("errorDetails", e.getClass().getSimpleName());
            return "error-page"; 
        }
    }
    
    @GetMapping("/simple-test")
    public String simpleTest(Model model) {
        model.addAttribute("message", "OneShop is working on Render!");
        model.addAttribute("timestamp", new java.util.Date());
        return "simple-test";
    }
}
